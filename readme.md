# Valheim GKE Server

This repo contains all things necessary to automate setting up a Valheim server in GKE.

## Architecture
![image](https://user-images.githubusercontent.com/31193909/137343959-1e86e73e-205c-4a79-99d5-2788545795a6.png)

## Requirements

* Helm > v3.0
* Terraform > v14.0

## Getting started
### Cluster setup
You can skip this if you already have a GKE cluster. Autopilot is not supported but may work. You can't add capabilities and this container modifies CAP_SYS_NICE so it may impact performance.

0) `cp terraform.tfvars.example terraform.tfvars`
1) edit `terraform.tfvars` (see below for inputs)
2) `make init`, `make apply`

### Starting server 
`make start` or `./start_server.sh`

This script will invoke the Cloud Function to scale up the node pool, print logs if there is an error, otherwise wait for the pod to be marked as ready

### Terraform Commands
* `make init`
* `make plan`
* `make apply`
* `make docs` - Generate TF docs

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apis_required"></a> [apis\_required](#input\_apis\_required) | a list of APIs to enable | `list(string)` | n/a | yes |
| <a name="input_artifactrepo"></a> [artifactrepo](#input\_artifactrepo) | Name of AR to create | `string` | `"blank"` | no |
| <a name="input_backup_cf_memory"></a> [backup\_cf\_memory](#input\_backup\_cf\_memory) | MB to give the backup function. Must exceed the size of your backup file | `number` | n/a | yes |
| <a name="input_backup_function_schedule"></a> [backup\_function\_schedule](#input\_backup\_function\_schedule) | cron schedule for backup in UTC | `string` | `"0 9 * * *"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name to create. Used to store world backups | `string` | n/a | yes |
| <a name="input_cloudscheduler_location"></a> [cloudscheduler\_location](#input\_cloudscheduler\_location) | Location for cloud scheduler | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of GKE cluster | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the container in the pod | `string` | n/a | yes |
| <a name="input_create_artifact_registry"></a> [create\_artifact\_registry](#input\_create\_artifact\_registry) | n/a | `bool` | n/a | yes |
| <a name="input_dr_region"></a> [dr\_region](#input\_dr\_region) | The DR region to host the DR bucket in | `string` | n/a | yes |
| <a name="input_ip_range_pods"></a> [ip\_range\_pods](#input\_ip\_range\_pods) | The NAME of the secondary range to use for pods. Note this MUST exist already. | `string` | `"pods"` | no |
| <a name="input_ip_range_services"></a> [ip\_range\_services](#input\_ip\_range\_services) | The NAME of the secondary range to use for services. Note this MUST exist already. | `string` | `"services"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Type to use for node pool | `string` | `"e2-standard-2"` | no |
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | A list of cidrs to allow to talk to the control plane | `list(object({ cidr_block = string, display_name = string }))` | n/a | yes |
| <a name="input_metrics_baseline"></a> [metrics\_baseline](#input\_metrics\_baseline) | Threshold CPU value to scaledown. Defines cluster idle state. Uses container/cpu/core\_usage\_time metric | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to use | `string` | `"default"` | no |
| <a name="input_network"></a> [network](#input\_network) | The VPC network to host the cluster in | `string` | `"default"` | no |
| <a name="input_project"></a> [project](#input\_project) | GCP Project to create resources in | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `string` | n/a | yes |
| <a name="input_scaledown_function_schedule"></a> [scaledown\_function\_schedule](#input\_scaledown\_function\_schedule) | cron schedule for backup in UTC | `string` | `"0 * * * *"` | no |
| <a name="input_scaleup_users"></a> [scaleup\_users](#input\_scaleup\_users) | A list of principals which are allowed to invoke the scale up function | `list(string)` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The subnetwork to host the cluster in | `string` | `"default"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Which zones to make the cluster in. Set to a single zone for free tier | `list(string)` | n/a | yes |



### Server deployment

1) Get kubectl config 
```
gcloud container clusters get-credentials (cluster name) --region (region) 
```

2) Deploy helm chart
It will prompt for a password so it is not stored in your history.

```
scripts/create_helm_server.sh (install|upgrade)
```

Server config data (world, config) is stored on a PVC and server backups are copied to GCS. This means it doesn't really matter if you lose your cluster you just need your backup zip. 

## Components
GKE Cluster and node pool - these run the workloads
Backup Cloud Function + Cloud Scheduler job - grabs a daily backup and optionally copies it to a secondary bucket
Scaledown Cloud Function + Cloud Scheduler job - checks the pod CPU metrics and determines when to scale node pool to 0
Scaleup Cloud Function - scales node pool to 1 upon invocation 

## Credits
This uses a modified helm chart from https://addyvan.github.io/valheim-k8s/
This uses the container from https://github.com/lloesche/valheim-server-docker
