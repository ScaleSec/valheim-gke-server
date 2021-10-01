package scaleup

import (
	"context"
	"fmt"
	"os"

	container "cloud.google.com/go/container/apiv1"
	log "github.com/sirupsen/logrus"
	containerpb "google.golang.org/genproto/googleapis/container/v1"
)

var (
	clusterName, clusterNamePresent   = os.LookupEnv("CLUSTER_NAME")
	project, ProjectPresent           = os.LookupEnv("PROJECT_ID")
	nodePoolName, nodePoolNamePresent = os.LookupEnv("NODEPOOL_NAME")
	location, locationPresent         = os.LookupEnv("LOCATION")
	req                               *containerpb.SetNodePoolSizeRequest
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
}

// scale node pool up or down
func scale(size int32) (req *containerpb.SetNodePoolSizeRequest) {
	req = &containerpb.SetNodePoolSizeRequest{
		NodeCount: size,
		Name:      fmt.Sprintf("projects/%s/locations/%s/clusters/%s/nodePools/%s", project, location, clusterName, nodePoolName),
	}

	return req
}

func Scaleup(ctx context.Context, e interface{}) error {
	log.Info("Starting run")
	client, err := container.NewClusterManagerClient(ctx)
	if err != nil {
		log.Fatal("Error initializing client")
	}
	defer client.Close()

	// get nodepool info
	req := &containerpb.GetNodePoolRequest{
		Name: fmt.Sprintf("projects/%s/locations/%s/clusters/%s/nodePools/%s", project, location, clusterName, nodePoolName),
	}
	resp, err := client.GetNodePool(ctx, req)
	if err != nil {
		log.Fatal(err)
	}

	if resp.Status != 2 {
		log.Fatal("Cluster is not in RUNNING state")
	}

	if resp.InitialNodeCount != 0 {
		log.Info("Cluster is already at scale. Exiting")
		return nil
	}

	log.Infof("Cluster count is %d", resp.InitialNodeCount)

	log.Info("Signal received. Scaling up cluster")
	scaleReq := scale(1)
	scaleResp, err := client.SetNodePoolSize(ctx, scaleReq)
	if err != nil {
		log.Fatal(err)
	}

	// might be used later
	_ = scaleResp

	log.Info("Finished")

	return nil

}
