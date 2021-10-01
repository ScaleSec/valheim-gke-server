package scaler

import (
	"context"
	"fmt"
	"os"
	"strconv"

	container "cloud.google.com/go/container/apiv1"
	monitoringpb "google.golang.org/genproto/googleapis/monitoring/v3"

	// "google.golang.org/api/iterator"

	monitoring "cloud.google.com/go/monitoring/apiv3/v2"
	log "github.com/sirupsen/logrus"
	containerpb "google.golang.org/genproto/googleapis/container/v1"
)

var (
	clusterName, clusterNamePresent     = os.LookupEnv("CLUSTER_NAME")
	project, ProjectPresent             = os.LookupEnv("PROJECT_ID")
	nodePoolName, nodePoolNamePresent   = os.LookupEnv("NODEPOOL_NAME")
	location, locationPresent           = os.LookupEnv("LOCATION")
	containerName, containerNamePresent = os.LookupEnv("CONTAINER_NAME")
	baselineValue, baselineValuePresent = os.LookupEnv("METRICS_BASELINE")
	req                                 *containerpb.SetNodePoolSizeRequest
)

func init() {
	if !clusterNamePresent {
		log.Fatal("CLUSTER_NAME is unset")
	}
	if !ProjectPresent {
		log.Fatal("PROJECT_ID is unset")
	}
	if !nodePoolNamePresent {
		log.Fatal("NODEPOOL_NAME is unset")
	}
	if !locationPresent {
		log.Fatal("LOCATION is unset")
	}
	if !containerNamePresent {
		log.Fatal("CONTAINER_NAME is unset")
	}
	if !baselineValuePresent {
		log.Fatal("METRICS_BASELINE is unset")
	}
}

// get cpu cluster
func getMetrics(ctx context.Context) bool {

	client, err := monitoring.NewQueryClient(ctx)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	// convert baseline value to a double for metrics
	baseline, _ := strconv.ParseFloat(baselineValue, 32)

	// get the avg CPU metrics for last 10 min. Returns the value and also a bool if the value is greater than the defined baseline
	cpuReq := &monitoringpb.QueryTimeSeriesRequest{
		Name:  fmt.Sprintf("projects/%s", project),
		Query: fmt.Sprintf("fetch k8s_container | metric 'kubernetes.io/container/cpu/core_usage_time' | filter (metadata.system_labels.top_level_controller_name == '%s' && metadata.system_labels.top_level_controller_type == 'Deployment') && (resource.cluster_name == '%s' && resource.location == '%s') | align rate(10m)| every 10m| group_by [], [value_core_usage_time_mean: mean(value.core_usage_time)] | condition lt(val(), %g's{CPU}/s')", containerName, clusterName, location, baseline),
	}
	cpuRespIt := client.QueryTimeSeries(ctx, cpuReq)
	cpuResp, err := cpuRespIt.Next()
	if err != nil {
		log.Fatal(err)
	}

	return cpuResp.PointData[0].Values[0].GetBoolValue()
}

func getPodAge(ctx context.Context) float64 {
	client, err := monitoring.NewQueryClient(ctx)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	uptimeReq := &monitoringpb.QueryTimeSeriesRequest{
		Name:  fmt.Sprintf("projects/%s", project),
		Query: fmt.Sprintf("fetch k8s_container | metric 'kubernetes.io/container/uptime' | filter (metadata.system_labels.top_level_controller_name == '%s' && metadata.system_labels.top_level_controller_type == 'Deployment') && (resource.cluster_name == '%s' && resource.location == '%s') | group_by 10m, [value_uptime_max: max(value.uptime)] | every 1m | group_by [], [value_uptime_max_max: max(value_uptime_max)]", containerName, clusterName, location),
	}
	uptimeReqIt := client.QueryTimeSeries(ctx, uptimeReq)
	uptime, err := uptimeReqIt.Next()
	if err != nil {
		log.Fatal(err)
	}

	return uptime.PointData[0].Values[0].GetDoubleValue()
}

// scale node pool up or down
func scale(size int32) (req *containerpb.SetNodePoolSizeRequest) {
	req = &containerpb.SetNodePoolSizeRequest{
		NodeCount: size,
		Name:      fmt.Sprintf("projects/%s/locations/%s/clusters/%s/nodePools/%s", project, location, clusterName, nodePoolName),
	}

	return req
}

func Scaledown(ctx context.Context, e interface{}) error {
	client, err := container.NewClusterManagerClient(ctx)
	if err != nil {
		log.Fatal("Error initializing client")
	}
	defer client.Close()

	// get nodepool info
	nodeReq := &containerpb.GetNodePoolRequest{
		Name: fmt.Sprintf("projects/%s/locations/%s/clusters/%s/nodePools/%s", project, location, clusterName, nodePoolName),
	}
	nodeResp, err := client.GetNodePool(ctx, nodeReq)
	if err != nil {
		log.Fatal(err)
	}

	// check if cluster is in a running state
	if nodeResp.Status != 2 {
		log.Fatal("Cluster is not in RUNNING state")
	}

	// check if node pool is 0, do nothing and exit
	if nodeResp.InitialNodeCount == 0 {
		log.Info("Cluster is already at 0. Exiting")
		return nil
	}

	// check if cluster has been scaled up in last 5 min
	if getPodAge(ctx) < 300 {
		log.Info("Pod is under 5 minutes old. Not scaling down")
		return nil
	}

	// if cluster is under the baseline, scale to 0
	if getMetrics(ctx) {
		log.Info("Cluster idle. Scaling down cluster")
		
		req = scale(0)
		resp, err := client.SetNodePoolSize(ctx, req)
		if err != nil {
			log.Fatal(err)
		}

		// might be used later
		_ = resp
	}

	log.Info("Finished")

	return nil
}
