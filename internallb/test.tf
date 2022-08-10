data "google_compute_address" "my_address" {
  name = "test-address"
}
output "instance-zone" {
  value = data.google_compute_address.region
}