provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
locals {
  machine_type = lookup(var.machine_type,var.environment)
}
resource "google_compute_region_instance_template" "app_server_templates" {
  name           = "appserver-template"
  machine_type   = local.machine_type
  disk {
    source_image = "projects/centos-cloud/global/images/centos-7-v20231010"
    boot = true
    disk_size_gb = 80
  }  
  network_interface {
    network = "default"
  }
}
resource "google_compute_instance_group_manager" "app_server_group" {
  name="app-server-grp"
  base_instance_name = "app-server"
  zone = "us-central1-a"
  version {
    name = "appserver"
    instance_template = google_compute_region_instance_template.app_server_templates.id
  }
  target_size = 2
}