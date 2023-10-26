provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
data "google_project_iam_policy" "pro_policy" {
  project  = "wise-shell-330415"
}
output "pro_policy" {
  value = data.google_project_iam_policy.pro_policy
}
/*resource "google_service_account" "app-server-sa" {
  account_id   = "app-server-sa"
  display_name = "A service account that create for storage"
}*/