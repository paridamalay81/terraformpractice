resource "google_compute_address" "vip_address" {
  name         = "my-tcp-lb"
  address_type = "INTERNAL"
  purpose      = "SHARED_LOADBALANCER_VIP"
  region       = "us-central1"
}

resource "google_compute_forwarding_rule" "frontend" {
  name                  = "frontend-tcp"
  region                = "us-central1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend.self_link
  ip_address            = google_compute_address.vip_address.address
  ip_protocol           = "tcp"
  port_range = var.port-list
}
resource "google_compute_region_backend_service" "backend" {
  
  name             = "tcp-lb-test"
  region           = "us-central1"
  protocol         = "tcp"
  timeout_sec      = 10
  backend {
    group          = google_compute_instance_group.instance_group.id
    balancing_mode = "CONNECTION"
  }

  health_checks = [
    compact(
      concat(
        google_compute_health_check.tcp_health_check.*.self_link,
        google_compute_health_check.http_health_check.*.self_link
      )
  )[0]]

}

resource "google_compute_health_check" "tcp_health_check" {
 
  name    = "tcp-hc"

  tcp_health_check {
    port = "80"
  }

  log_config {
    enable = true
  }
}

resource "google_compute_health_check" "http_health_check" {
  

 name    = "http-hc"

  http_health_check {
    port = "80"
  }

  log_config {
    enable = true
  }

}
resource "google_compute_instance_group" "instance_group" {
  name        = "myinstancegrp"
  description = "${var.service_name} Unmanaged Instance Group"
  instances = [
    data.google_compute_instance.instance.self_link,
  ]
  named_port {
    name = "http"
    port = "80"
  }
  zone = "us-central1-a"
}