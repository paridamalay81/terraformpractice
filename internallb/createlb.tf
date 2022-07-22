
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
    network = "default"
    load_balancing_scheme = "EXTERNAL_MANAGED"
}
resource "google_compute_target_http_proxy" "http-proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.http-url.id
}
resource "google_compute_url_map" "http-url" {
  name            = "http-url"
  default_service = google_compute_backend_service.http-backend.id

  host_rule {
    hosts        = ["*:80"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.http-backend.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.http-backend.id
    }
  }
}
resource "google_compute_backend_service" "http-backend" {
  name          = "http-backend"
  health_checks = [google_compute_region_health_check.default.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"
  locality_lb_policy = "ROUND_ROBIN"
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