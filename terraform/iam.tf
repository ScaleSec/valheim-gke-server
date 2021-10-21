module "workload-identity" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version = "16.1.0"

  depends_on = [
    module.gke.node_pools_names
  ]

  name                            = google_service_account.workloadid.account_id
  namespace                       = var.namespace
  project_id                      = var.project
  automount_service_account_token = true
  use_existing_gcp_sa             = true
}

resource "google_service_account" "workloadid" {
  account_id = "scaleheim-sa"
}

resource "google_project_iam_member" "logs1" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.workloadid.email}"
}
resource "google_project_iam_member" "logs2" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.workloadid.email}"
}
resource "google_project_iam_member" "logs3" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.workloadid.email}"
}
resource "google_project_iam_member" "logs4" {
  role   = "roles/stackdriver.resourceMetadata.writer"
  member = "serviceAccount:${google_service_account.workloadid.email}"
}

resource "google_storage_bucket_iam_member" "objectadmin" {
  bucket = google_storage_bucket.backups.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.workloadid.email}"
}

resource "google_artifact_registry_repository_iam_member" "valheim" {
  count = var.create_artifact_registry ? 1 : 0

  provider = google-beta

  location   = google_artifact_registry_repository.valheim[0].location
  repository = google_artifact_registry_repository.valheim[0].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.workloadid.email}"
}

resource "google_service_account" "backup" {
  account_id   = "valheim-backup"
  display_name = "SA to backup"
}
resource "google_service_account" "scaleup" {
  account_id   = "valheim-scaleup"
  display_name = "SA to scaleup"
}
resource "google_service_account" "scaledown" {
  account_id   = "valheim-scaledown"
  display_name = "SA to scaledown"
}
resource "google_service_account" "bot" {
  account_id   = "valheim-bot"
  display_name = "SA for bot"
}
resource "google_project_iam_member" "scaleup" {
  role   = "roles/container.admin"
  member = "serviceAccount:${google_service_account.scaleup.email}"
}
resource "google_project_iam_member" "scaledown-cluster" {
  role   = "roles/container.admin"
  member = "serviceAccount:${google_service_account.scaledown.email}"
}
resource "google_project_iam_member" "scaledown-monitor" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.scaledown.email}"
}

# Allow backup SA to access the backup bucket
resource "google_storage_bucket_iam_member" "backup-view" {
  bucket = google_storage_bucket.backups.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.backup.email}"
}

resource "google_storage_bucket_iam_member" "backup-write" {
  bucket = google_storage_bucket.backups.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.backup.email}"
}

resource "google_storage_bucket_iam_member" "backupDr-write" {
  bucket = google_storage_bucket.backupsDisaster.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.backup.email}"
}
resource "google_cloudfunctions_function_iam_binding" "scaleup" {
  cloud_function = google_cloudfunctions_function.scaleup.name
  role           = "roles/cloudfunctions.invoker"
  members        = var.scaleup_users
}
