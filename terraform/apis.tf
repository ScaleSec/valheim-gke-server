resource "google_project_service" "apis" {
  count = length(var.apis_required)

  project = var.project
  service = var.apis_required[count.index]

  disable_dependent_services = true
  disable_on_destroy         = false
}