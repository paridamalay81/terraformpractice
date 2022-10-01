resource "google_compute_instance" "vm-machines" {
  name = "vm-instance-${count.index}"
  machine_type = "e2-medium"
  zone = "us-central1-a"
  tags = ["webserver"]
  count = length(var.instance_name)
  metadata = {
    ssh-keys="${var.username}:${file("~/.ssh/id_rsa.pub")}"
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
  provisioner "remote-exec" {
    scripts = [
      "/home/malayparida009/terraformpractice/internallb/modules/create-vm-machines/install_run_apache_http_80.sh"
    ]
    connection {
      type = "ssh"
      host = google_compute_instance.vm-machines[count.index].network_interface.0.network_ip
      user = var.username
      private_key= "${file("~/.ssh/id_rsa")}"
    }
  }
  }
  resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "default"
   allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["webserver"]
}
output "webserver_lb_id" {
  value = google_compute_instance.vm-machines[0].id
}