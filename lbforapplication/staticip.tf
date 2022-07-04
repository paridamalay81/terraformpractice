resource "google_compute_address" "saticipForLB" {
  name = "staticipforlb"
  address_type = "INTERNAL"
}