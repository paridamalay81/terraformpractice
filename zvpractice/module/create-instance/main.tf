provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
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