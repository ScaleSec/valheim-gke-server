# Random string for bucket name
resource "random_string" "bucket" {
  length  = 8
  lower   = true
  upper   = false
  special = false
}

# Bucket to store all code
resource "google_storage_bucket" "bucket" {
  name = "cf-backup-${random_string.bucket.result}"
}

########################
# Backup Function
########################
# Topic to trigger CF
resource "google_pubsub_topic" "backup" {
  depends_on = [
    google_project_service.apis
  ]

  name = "backup-trigger"

}

# Cloud Scheduler to invoke pubsub
resource "google_cloud_scheduler_job" "backup" {
  depends_on = [
    google_project_service.apis
  ]

  name        = "backup-job"
  description = "triggers backup cloud function"
  schedule    = var.backup_function_schedule

  region = var.cloudscheduler_location

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.backup.id
    data       = base64encode("backup")
  }
}

# backup Source code
data "archive_file" "backup" {
  type        = "zip"
  source_dir  = "${abspath("../")}/cloudfunctions/backup"
  output_path = "/tmp/backup.zip"
}

# Archive file
resource "google_storage_bucket_object" "backup" {
  name   = "backup-${data.archive_file.backup.output_md5}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.backup.output_path

  metadata = {}

}

# backup Cloud function
resource "google_cloudfunctions_function" "backup" {
  depends_on = [
    google_project_service.apis
  ]

  name        = "backup"
  description = "Daily backup"
  runtime     = "go116"

  available_memory_mb   = var.backup_cf_memory
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.backup.name
  entry_point           = "Backup"

  labels = {
    function = "backup"
  }

  service_account_email = google_service_account.backup.email

  environment_variables = {
    BUCKET_NAME      = google_storage_bucket.backups.name
    BUCKET_NAME_DR   = google_storage_bucket.backupsDisaster.name
    BACKUP_FILE_NAME = "scaleheim"
  }

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.backup.id
  }
}

########################
# Scaledown Function
########################
resource "google_pubsub_topic" "scaledown" {
  depends_on = [
    google_project_service.apis
  ]

  name = "scaledown-trigger"

}

# Cloud Scheduler to invoke pubsub
resource "google_cloud_scheduler_job" "scaledown" {
  depends_on = [
    google_project_service.apis
  ]

  name        = "scaledown-job"
  description = "triggers scaledown cloud function"
  schedule    = var.scaledown_function_schedule

  region = var.cloudscheduler_location

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.scaledown.id
    data       = base64encode("scaledown")
  }
}

# Source code
data "archive_file" "scaledown" {
  type        = "zip"
  source_dir  = "${abspath("../")}/cloudfunctions/scaledown"
  output_path = "/tmp/scaledown.zip"
}

# Archive file
resource "google_storage_bucket_object" "scaledown" {
  name   = "scaledown-${data.archive_file.scaledown.output_md5}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.scaledown.output_path

  metadata = {}

}

# backup Cloud function
resource "google_cloudfunctions_function" "scaledown" {
  depends_on = [
    google_project_service.apis
  ]

  name        = "scaledown"
  description = "scaledown"
  runtime     = "go116"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.scaledown.name
  entry_point           = "Scaledown"

  labels = {
    function = "scaledown"
  }

  service_account_email = google_service_account.scaledown.email

  environment_variables = {
    CLUSTER_NAME     = var.cluster_name
    PROJECT_ID       = var.project
    NODEPOOL_NAME    = module.gke.node_pools_names[0]
    LOCATION         = var.zones[0]
    CONTAINER_NAME   = var.container_name
    METRICS_BASELINE = var.metrics_baseline
  }

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.scaledown.id
  }

}

########################
# Scaleup Function
########################

# Source code
data "archive_file" "scaleup" {
  type        = "zip"
  source_dir  = "${abspath("../")}/cloudfunctions/scaleup"
  output_path = "/tmp/scaleup.zip"
}

# Archive file
resource "google_storage_bucket_object" "scaleup" {
  name   = "scaleup-${data.archive_file.scaleup.output_md5}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.scaleup.output_path

  metadata = {}

}

# backup Cloud function
resource "google_cloudfunctions_function" "scaleup" {
  depends_on = [
    google_project_service.apis
  ]

  name        = "scaleup"
  description = "scaleup"
  runtime     = "go116"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.scaleup.name
  entry_point           = "Scaleup"

  labels = {
    function = "scaleup"
  }

  service_account_email = google_service_account.scaleup.email

  environment_variables = {
    CLUSTER_NAME  = var.cluster_name
    PROJECT_ID    = var.project
    NODEPOOL_NAME = module.gke.node_pools_names[0]
    LOCATION      = var.zones[0]
  }

  trigger_http = true

}

########################
# Bot Function
########################

# Source code
data "archive_file" "bot" {
  type        = "zip"
  source_dir  = "${abspath("../")}/cloudfunctions/bot"
  output_path = "/tmp/bot.zip"
}

# Archive file
resource "google_storage_bucket_object" "bot" {
  name   = "bot-${data.archive_file.scaleup.output_md5}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.bot.output_path

  metadata = {}

}
resource "google_cloudfunctions_function" "bot" {
  depends_on = [
    google_project_service.apis
  ]

  name        = "interactions"
  description = "interactions"
  runtime     = "go116"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.bot.name
  entry_point           = "Interactions"

  labels = {
    function = "Interactions"
  }

  service_account_email = google_service_account.bot.email

  environment_variables = {
    DISCORD_PUBLIC_KEY = var.public_key

  }

  trigger_http = true

}