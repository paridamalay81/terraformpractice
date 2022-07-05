resource "google_compute_instance" "backend_instance" {
  name         = var.backend_instance_name
  machine_type = "e2-medium"
  zone         = var.instance_zone
  tags = ["webserver"]

  boot_disk {
    initialize_params {
      image = "CentOS 7"
    }
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt update 
    apt -y install apache2
    echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
  EOF
}

resource "google_compute_instance_group" "backend-instance-group" {
  name = var.instance_group_name
  zone = var.instance_zone
  instances = [ google_compute_instance.backend_instance.id ]
  named_port {
    name = "http"
    port = "80"
  }
  named_port {
    name = "https"
    port = "443"
  }

}
resource "google_compute_region_backend_service" "backend_service_https" {
  name = "backend_service_https"
  load_balancing_scheme = "INTERNAL_MANAGED"
  locality_lb_policy = "ROUND_ROBIN"
  session_affinity = "NONE"
  protocol = "https"
  port_name = "https"
  health_checks = [google_compute_health_check.backend_service-health_check.id]
  backend {
    group = google_compute_instance_group.backend-instance-group.id
    balancing_mode = "UTILIZATION"
  }
}
resource "google_compute_region_backend_service" "backend_service_http" {
  name = "backend_service_http"
  load_balancing_scheme = "INTERNAL_MANAGED"
  locality_lb_policy = "ROUND_ROBIN"
  session_affinity = "NONE"
  protocol = "http"
  port_name = "http"
  health_checks = [google_compute_health_check.backend_service-health_check.id]
  backend {
    group = google_compute_instance_group.backend-instance-group.id
    balancing_mode = "UTILIZATION"
  }
}
resource "google_compute_health_check" "backend_service-health_check" {
  name               = "backend_service-health_check"
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "80"
  }
}
resource "google_compute_forwarding_rule" "frontend_http" {
  name                  = "frontend_http"
  region                = var.region
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.proxy_http.id
  network_tier          = "PREMIUM"
}
resource "google_compute_region_target_http_proxy" "proxy_http" {
  name     = "proxy_http"
  region   = var.region
  url_map  = google_compute_region_url_map.url_map.id
}
resource "google_compute_forwarding_rule" "frontend_https" {
  name                  = "frontend_https"
  region                = var.region
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "HTTPS"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_http_proxy.proxy_https.id
  network_tier          = "PREMIUM"
}
resource "google_compute_region_target_http_proxy" "proxy_https" {
  name     = "proxy_https"
  region   = var.region
  url_map  = google_compute_region_url_map.url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.default.self_link]
}

resource "google_compute_region_ssl_certificate" "default" {
  name_prefix = "my-certificate-"
  private_key = tls_private_key.default.private_key_pem
  certificate = tls_self_signed_cert.default.cert_pem
  region      = var.region
  lifecycle {
    create_before_destroy = true
  }
}
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  key_algorithm   = tls_private_key.default.algorithm
  private_key_pem = tls_private_key.default.private_key_pem

  # Certificate expires after 12 hours.
  validity_period_hours = 24

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["${var.host_name}"]

  subject {
    common_name  = "${var.host_name}"
    organization = "${var.host_name}"
  }
}
# URL map
resource "google_compute_region_url_map" "url_map" {
  name            = "http_url_map"
  region          = var.region
 
  host_rule {
    hosts        = ["${var.host_name}:80"]
    path_matcher = "http_path"
  }
  host_rule {
    hosts        = ["${var.host_name}:443"]
    path_matcher = "https_path"
  }
  path_matcher {
    name            = "https_path"
    default_service = google_compute_region_backend_service.backend_service_https.id
  }
}