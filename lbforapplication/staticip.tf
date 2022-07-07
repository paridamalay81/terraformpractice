resource "google_compute_address" "saticipForLB" {
  name = "staticipforlb"
  address_type = "INTERNAL"
  purpose = "SHARED_LOADBALANCER_VIP"
}