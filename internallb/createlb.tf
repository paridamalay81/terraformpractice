
resource "google_compute_instance" "backend_instance" {
  name         = "backend-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags = ["webserver"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20220303"
    }
  }
  network_interface {
    network = "default"
    access_config {
      
    }
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo yum update httpd
    sudo yum install httpd -y
    sudo systemctl start httpd
    echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
  EOF
}
resource "google_compute_global_forwarding_rule" "frontend-http"{
    name = "frontend-http"
    target = google_compute_target_http_proxy.http-proxy.id
    ip_address = google_compute_global_address.saticipForLB.id
    load_balancing_scheme = "EXTERNAL_MANAGED"
    port_range = "80"
}
resource "google_compute_target_http_proxy" "http-proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.http-url.id
}
resource "google_compute_url_map" "http-url" {
  name            = "http-url"
  default_service = google_compute_backend_service.http-backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.http-backend.id

    path_rule {
      paths   = ["/"]
      service = google_compute_backend_service.http-backend.id
    }
  }
}
resource "google_compute_backend_service" "http-backend" {
  name          = "http-backend"
  health_checks = [google_compute_health_check.default.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"
  locality_lb_policy = "ROUND_ROBIN"
   protocol = "HTTP"
  backend {
    group = google_compute_instance_group.backend-instance-grp.id
  }
}

resource "google_compute_health_check" "default" {
  name               = "health-check"
  timeout_sec         = 5
  check_interval_sec  = 5
  http_health_check {
    port = "80"
    request_path       = "/"
  }
}
resource "google_compute_instance_group" "backend-instance-grp" {
  name        = "webservers"
  description = "Terraform test instance group"

  instances = [
    google_compute_instance.backend_instance.id    
  ]

  named_port {
    name = "http"
    port = "80"
  }
  zone = "us-central1-a"
}
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["webserver"]
}
//Adding for https(443)
resource "google_compute_instance" "backend_instance_https" {
  name         = "backend-instance-https"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags = ["webserver-https"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20220303"
    }
  }
  network_interface {
    network = "default"
    access_config {
      
    }
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo yum update httpd
    sudo yum install httpd -y
    sudo systemctl start httpd
    echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
  EOF
}
resource "google_compute_global_forwarding_rule" "frontend-https" {
  name = "frontend-https"
  target = google_compute_target_https_proxy.proxy-https.id
  ip_address = google_compute_global_address.saticipForLB.id
  ip_protocol = "HTTPS"
  port_range = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  locality_lb_policy = "ROUND_ROBIN"
}
resource "google_compute_target_https_proxy" "proxy-https" {
  name = "proxy-https"
  url_map = google_compute_url_map.https-url.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}
resource "google_compute_url_map" "https-url" {
  name            = "https-url"
  default_service = google_compute_backend_service.https-backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.https-backend.id

    path_rule {
      paths   = ["/"]
      service = google_compute_backend_service.https-backend.id
    }
  }
}
resource "google_compute_ssl_certificate" "default" {
  name_prefix = "my-certificate-"
  private_key = tls_private_key.default.private_key_pem
  certificate = tls_self_signed_cert.default.cert_pem
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

  dns_names = ["test.com"]

  subject {
    common_name  = "test.com"
    organization = "test"
  }
}
resource "google_compute_backend_service" "https-backend" {
  name = "https-backend"
  health_checks = [ google_compute_health_check.default.id ]
  protocol = "HTTPS"
  backend {
    group = google_compute_instance_group.instance-https.id
  }

}
resource "google_compute_instance_group" "instance-https" {
  name        = "webservers-https"
  description = "Terraform test instance group"

  instances = [
    google_compute_instance.backend_instance_https.id    
  ]

  named_port {
    name = "http"
    port = "80"
  }
  zone = "us-central1-a"
}
resource "google_compute_firewall" "default-https" {
  name    = "test-firewall-https-instance"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["webserver-https"]
}