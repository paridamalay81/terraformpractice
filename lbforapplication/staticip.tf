resource "google_compute_address" "saticipForLB" {
  name = "staticipforlb"
  address_type = "EXTERNAL"
  purpose = "SHARED_LOADBALANCER_VIP"
  network = "default"
}