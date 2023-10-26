provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
data "google_project_iam_policy" "name" {
  project  = "wise-shell-330415"
}
/*resource "google_service_account" "app-server-sa" {
  account_id   = "app-server-sa"
  display_name = "A service account that create for storage"
}*/