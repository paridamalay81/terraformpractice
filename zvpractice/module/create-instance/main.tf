provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
resource "google_service_account" "app-server-sa" {
  account_id   = "app-server-sa"
  display_name = "A service account that create for storage"
}
resource "google_compute_instance" "app-server" {
  name = "app-server-with-storage"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }
  network_interface {
    network = "default"
  }
}
resource "google_project_iam_member" "gce-default-account-iam" {
  project = "wise-shell-330415"  
  role               = "roles/secretmanager.admin"
  member             ="serviceAccount:${google_service_account.app-server-sa.email}"
}
resource "google_service_account_iam_member" "gce-default-account-iam-role" {
  service_account_id = google_service_account.app-server-sa.name
  role               = "roles/resourcemanager.projectIamAdmin"
  member             = google_service_account.app-server-sa.email
}