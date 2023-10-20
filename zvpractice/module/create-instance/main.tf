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
resource "google_service_account_iam_member" "gce-default-account-iam" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/storage.admin"
  member             = google_service_account.app-server-sa.email
}