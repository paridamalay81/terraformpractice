data "google_compute_zones" "available-zones" {
  status = UP
}
resource "google_compute_instance" "vm-machines" {
  name = "vm-instance-${count.index}"
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
  count = var.environment == "dev" ? 1 : 3
}