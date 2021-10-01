<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_google"></a> [google](#provider\_google) | 3.84.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 3.84.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | 16.1.0 |
| <a name="module_workload-identity"></a> [workload-identity](#module\_workload-identity) | terraform-google-modules/kubernetes-engine/google//modules/workload-identity | 16.1.0 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_artifact_registry_repository.valheim](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_artifact_registry_repository) | resource |
| [google-beta_google_artifact_registry_repository_iam_member.valheim](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_artifact_registry_repository_iam_member) | resource |
| [google_cloud_scheduler_job.backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloud_scheduler_job.scaledown](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloudfunctions_function.backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function.scaledown](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function.scaleup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function_iam_binding.scaleup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function_iam_binding) | resource |
| [google_project_iam_member.logs1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.logs2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.logs3](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.logs4](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.scaledown-cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.scaledown-monitor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.scaleup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_pubsub_topic.backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.scaledown](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_service_account.backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.scaledown](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.scaleup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.workloadid](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.backups](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.backupsDisaster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.backup-view](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.backup-write](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.backupDr-write](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.objectadmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.scaledown](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.scaleup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [random_string.bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [archive_file.backup](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.scaledown](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.scaleup](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

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

## Outputs

No outputs.
<!-- END_TF_DOCS -->