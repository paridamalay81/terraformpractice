provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
data "google_project_iam_policy" "pro_policy" {
  project  = "wise-shell-330415"
}
resource "google_project_iam_member" "add_new_mem" {
  project = "wise-shell-330415"
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:291973166279-compute@developer.gserviceaccount.com"
}
output "pro_policy" {
  value = data.google_project_iam_policy.pro_policy
}
/*resource "google_service_account" "app-server-sa" {
  account_id   = "app-server-sa"
  display_name = "A service account that create for storage"
}*/