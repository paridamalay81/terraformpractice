locals {
  prefix = "web-server"
}
resource "google_compute_global_address" "external_webserver_https_lb_vip" {
    name = "ext-https-lb-vip"
    address_type = "EXTERNAL"  
}
resource "google_compute_global_forwarding_rule" "webserver_lb" {
  name = "${local.prefix}-lb"
  target = google_compute_target_http_proxy.webserver_lb.id
  ip_address = google_compute_global_address.external_webserver_https_lb_vip.id
  ip_protocol = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range = "80"
}
resource "google_compute_target_http_proxy" "webserver_lb" {
  name    = "${local.prefix}-lb-http-proxy"
  url_map = google_compute_url_map.url_map.id
}
resource "google_compute_url_map" "url_map" {
  name = "${local.prefix}-url-map"
  default_service = google_compute_backend_service.default.id
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name = "allpaths"
    path_rule {
      paths = ["/"]
      service = google_compute_backend_service.default.id
    }
  }
}

resource "google_compute_backend_service" "default" {
  name          = "backend-service"
  health_checks = [google_compute_http_health_check.default.id]
  backend {
    group = google_compute_instance_group.webservers_lb_instancegroup.id
  }
}

resource "google_compute_http_health_check" "default" {
  name               = "health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
resource "google_compute_instance_group" "webservers_lb_instancegroup" {
  name        = "instancegroup-lb"
  description = "Terraform test instance group"

  instances = [
    module.webserver_instance.webserver_lb_id
  ]
  named_port {
    name = "http"
    port = "80"
  }
zone = "us-central1-a"

}
module "webserver_instance" {
  source = "../create-vm-machines"
  instance_name = var.instance_name
  username = var.username
  key-ssh = var.key-ssh
  key-ssh-private = var.key-ssh-private
}