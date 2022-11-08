locals {
  zone = {
    instance1 = "us-central1-a"
    instance2 = "us-central1-c"
  }
}
resource "google_compute_instance_template" "as2_instance" {
  //name_prefix  = "remote-engine-"
  description  = "This template will be used for creating AS2 application RHEL7.9 instances"
  //machine_type = "n1-standard-8"
  machine_type = "e2-micro"
  tags = ["as2-dev"]
  disk {
    source_image = "centos-7-v20220303"
    disk_size_gb = "32"
    auto_delete  = true
    boot         = true
  }
  network_interface {
    subnetwork = "default"
    
  }
}

resource "google_compute_instance_from_template" "instance1" {
  name                     = list(var.instance_list,0)
  zone                     = local.zone.instance1
  source_instance_template = google_compute_instance_template.as2_instance.id

  
}

resource "google_compute_instance_from_template" "instance2" {
  name                     = list(var.instance_list,1)
  zone                     = local.zone.instance2
  source_instance_template = google_compute_instance_template.as2_instance.id

  
}
