resource "google_compute_instance" "vm-machines" {
  name = "vm-instance-${count.index}"
  machine_type = "e2-medium"
  zone = lookup(var.instance_zone,substr(var.instance_name["${count.index}"],0,3) == "mgo" ? 2 : 1,"us-west1")
  tags = ["webserver"]
  count = length(var.instance_name)
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
      install_run_apache_http_80.sh
    ]
    connection {
      type = ssh
      user = var.username
      host_key = var.key-ssh
    }
  }
   
}