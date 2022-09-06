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
  project          = var.project_id
  name             = "${var.service_name}-tcp"
  region           = var.region
  protocol         = var.backend_protocol
  timeout_sec      = 10
  session_affinity = var.session_affinity
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
  count = var.http_health_check ? 0 : 1

  project = var.project_id
  name    = "${var.service_name}-hc"

  tcp_health_check {
    port = var.health_check_port
  }

  log_config {
    enable = true
  }
}

resource "google_compute_health_check" "http_health_check" {
  count = var.http_health_check ? 1 : 0

  project = var.project_id
  name    = "${var.service_name}-hc"

  http_health_check {
    port = var.health_check_port
  }

  log_config {
    enable = true
  }

}