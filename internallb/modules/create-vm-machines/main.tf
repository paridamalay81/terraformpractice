resource "google_compute_instance" "vm-machines" {
  name = "vm-instance-${count.index}"
  machine_type = "e2-medium"
  zone = "us-central1-a"
  tags = ["webserver"]
  count = length(var.instance_name)
  metadata = {
    ssh-keys=var.key-ssh
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
      "install_run_apache_http_80.sh"
    ]
    connection {
      type = "ssh"
      host = google_compute_instance.vm-machines[count.index].network_interface.0.network_ip 
      user = var.username
      host_key = var.key-ssh
    }
  }
   
}