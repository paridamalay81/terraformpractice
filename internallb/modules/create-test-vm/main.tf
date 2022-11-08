locals {
    instance_name1 = element(var.instance_list,0)
    instance_name2 = element(var.instance_list,1)
    zone = {
        "local.instance_name1" = "us-central1-a"
        "local.instance_name2" = "us-east4-c"
    }
    regions = {
        "local.instance_name1" =  "us-central1"
        "local.instance_name2" = "us-east4"
    }
}

resource "google_compute_instance_template" "as2_instance_template1" {
  
  name = "as2-instance-template"
  description  = "This template will be used for creating AS2 application RHEL7.9 instances"
  machine_type = var.machine_type

  tags = ["as2-appserver-dev"]

  network_interface {
    subnetwork = "default"
  }

  disk {
    source_image = var.vm_source_image
    disk_size_gb = "80"
    auto_delete  = true
    boot         = true
  }

  disk {
    disk_name = "/mnt/data1"
    interface    = "NVME"     
    mode         = "READ_WRITE"
    disk_type    = "local-ssd"
    disk_size_gb = "50"
    type         = "SCRATCH"
    auto_delete  = true
    boot         = false
  } 
}
resource "google_compute_address" "remote_engine_studio_static_ip_test" {
  project      = var.project_id
  region       = var.region
  name         = "test-remote-engine"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = google_compute_instance_template.test_remote_engine.network_interface[0].subnetwork
  address      = ""
}

#For use by developers in Talend Studio
resource "google_compute_instance_from_template" "instance1" {
  name                     = local.instance_name1
  zone                     = "${local.zone}.${local.instance_name1}"
  source_instance_template = google_compute_instance_template.as2_instance_template1.id

}