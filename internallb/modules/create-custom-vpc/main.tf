locals {
  subnet-range = lookup(var.subnets,"${var.environment}"-"${var.spec_region}")
}
resource "google_compute_network" "custom_network" {
  name                    = "custom-network"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "custom_network_subnetwork" {
  name          = "custom_network_subnetwork-${var.environment}"
  ip_cidr_range = local.subnet-range
  region        = var.spec_region
  network       = google_compute_network.custom_network.id
 }