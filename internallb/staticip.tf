resource "google_compute_global_address" "saticipForLB" {
  name = "staticipforlb"
  address_type = "EXTERNAL"
}