data "google_client_config" "default" {}

# Required by the module
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# GKE Cluster
module "gke" {

  depends_on = [
    google_project_service.apis
  ]

  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "16.1.0"

  project_id      = var.project
  region          = var.region
  regional        = false
  zones           = var.zones
  release_channel = "STABLE"

  name = var.cluster_name

  network           = var.network
  subnetwork        = var.subnetwork
  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services

  add_cluster_firewall_rules = true
  remove_default_node_pool   = true
  http_load_balancing        = false
  horizontal_pod_autoscaling = false
  create_service_account     = false

  node_metadata              = "GKE_METADATA_SERVER"
  master_authorized_networks = var.master_authorized_networks

  node_pools = [
    {
      name            = "valheim"
      min_count       = 1
      max_count       = 1
      node_count      = 1
      auto_upgrade    = true
      disk_size_gb    = 100
      disk_type       = "pd-ssd"
      image_type      = "COS_CONTAINERD"
      machine_type    = var.machine_type
      service_account = google_service_account.workloadid.email
    }
  ]

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

resource "google_artifact_registry_repository" "valheim" {
  count = var.create_artifact_registry ? 1 : 0

  depends_on = [
    google_project_service.apis
  ]

  provider = google-beta

  location      = var.region
  repository_id = var.artifactrepo
  format        = "DOCKER"
}