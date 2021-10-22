variable "region" {
  description = "The region to host the cluster in"
  type        = string
}
variable "dr_region" {
  description = "The DR region to host the DR bucket in"
  type        = string
}

variable "zones" {
  description = "Which zones to make the cluster in. Set to a single zone for free tier"
  type        = list(string)
}

variable "cloudscheduler_location" {
  description = "Location for cloud scheduler"
  type        = string
}
variable "scaleup_users" {
  type        = list(string)
  description = "A list of principals which are allowed to invoke the scale up function"
}

variable "project" {
  description = "GCP Project to create resources in"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name to create. Used to store world backups"
  type        = string
}

variable "cluster_name" {
  description = "Name of GKE cluster"
  type        = string
}

variable "machine_type" {
  description = "Type to use for node pool"
  type        = string
  default     = "e2-standard-2"
}

variable "network" {
  description = "The VPC network to host the cluster in"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
  default     = "default"
}

variable "ip_range_pods" {
  description = "The NAME of the secondary range to use for pods. Note this MUST exist already."
  type        = string
  default     = "pods"
}

variable "ip_range_services" {
  description = "The NAME of the secondary range to use for services. Note this MUST exist already."
  type        = string
  default     = "services"
}

variable "master_authorized_networks" {
  description = "A list of cidrs to allow to talk to the control plane"
  type        = list(object({ cidr_block = string, display_name = string }))
}

variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
  default     = "default"
}

variable "artifactrepo" {
  description = "Name of AR to create"
  type        = string
  default     = "blank"
}

variable "create_artifact_registry" {
  type = bool
}

variable "backup_cf_memory" {
  description = "MB to give the backup function. Must exceed the size of your backup file"
  type        = number
}

variable "apis_required" {
  description = "a list of APIs to enable"
  type        = list(string)

}

variable "backup_function_schedule" {
  description = "cron schedule for backup in UTC"
  type        = string

  default = "0 9 * * *"
}

variable "container_name" {
  type        = string
  description = "Name of the container in the pod"

}

variable "metrics_baseline" {
  type        = string
  description = "Threshold CPU value to scaledown. Defines cluster idle state. Uses container/cpu/core_usage_time metric"
}
variable "scaledown_function_schedule" {
  description = "cron schedule for backup in UTC"
  type        = string

  default = "0 * * * *"
}

variable "public_key" {
  description = "Discord bot public key"
  type = string
}