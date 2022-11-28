locals {
  myname="webservers_app"
}
resource "google_compute_instance" "vm-machines" {
  name = "vm-instance-${count.index}"
  machine_type = "e2-medium"
  zone = "us-central1-a"
  tags = [local.myname]
  count = length(var.instance_name)
  metadata = {
    ssh-keys="${var.username}:${file("~/.ssh/id_rsa.pub")}"
  }
  labels = {
    local.myname = "true"
  }
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
}