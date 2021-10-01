# Bucket to use for backups
resource "google_storage_bucket" "backups" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = false

  # keep 3 new versions of the backup
  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
  versioning {
    enabled = true
  }
}

# The workload identity SA doesn't have access to this so we have a little more safety
# backup function will write to this
resource "google_storage_bucket" "backupsDisaster" {
  name          = "${var.bucket_name}-dr"
  location      = var.dr_region
  force_destroy = false

  # keep 1 new version of the backup
  lifecycle_rule {
    condition {
      num_newer_versions = 1
    }
    action {
      type = "Delete"
    }
  }
  versioning {
    enabled = true
  }
}