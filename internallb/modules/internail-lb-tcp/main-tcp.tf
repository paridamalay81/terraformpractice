resource "google_compute_address" "vip_address" {
  name         = "my-tcp-lb"
  address_type = "INTERNAL"
  purpose      = "SHARED_LOADBALANCER_VIP"
  region       = "us-central1"
}



resource "google_compute_target_tcp_proxy" "default" {
  name            = "test-proxy"
  backend_service = google_compute_backend_service.backend.id
}
resource "google_compute_backend_service" "backend" {
  
  name             = "tcp-lb-test"
  protocol         = "TCP"
  timeout_sec      = 10
  backend {
     group          = google_compute_instance_group.instance_group.id
     balancing_mode = "CONNECTION"
     max_connections = 1000
  }

  health_checks = [
    compact(
      concat(
        google_compute_health_check.tcp_health_check.*.self_link,
        google_compute_health_check.http_health_check.*.self_link
      )
  )[0]]

}

resource "google_compute_instance_group" "instance_group" {
  name        = "myinstancegrp"
  description = "Unmanaged Instance Group"
  instances = [
    google_compute_instance.instance.self_link,
  ]
  dynamic named_port {
    for_each        = toset(var.port_list)
    content {
     name = "http"
     port = "${named_port.value}"
    }
  }
  zone = "us-central1-a"
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

resource "google_compute_instance" "instance" {
   name = "vm-instance-test-lb"
  machine_type = "e2-medium"
  zone = "us-central1-a"
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