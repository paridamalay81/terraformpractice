provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
locals {
  machine_type = lookup(var.machine_type,var.environment)
  disk_prod = {   
    disk1 = ["pd-ssd","80","us-central1-a"]
    disk2 = ["pd-ssd","180","us-central1-a"]
  }
  disk_prod_attr = ["type","size","zone"] 
  prod_disk_helper={    
    for disk,disk_attr in local.disk_prod_attr:disk=>zipmap(local.disk_prod_attr,disk_attr)    
  }
}
output "disk_attr_map" {
  value = local.prod_disk_helper
}

/*resource "google_compute_region_instance_template" "app_server_templates" {
  name           = "appserver-template"
  machine_type   = local.machine_type
  disk {
    source_image = "projects/centos-cloud/global/images/centos-7-v20231010"
    boot = true
    disk_size_gb = 80
  }  
  dynamic "disk" {
    for_each = [for disk in google_compute_disk.app_server_vm_additional_disk:disk]
    content {
      disk_name = 
    }
  }
  network_interface {
    network = "default"
  }
}
resource "google_compute_instance_group_manager" "app_server_group" {
  name="app-server-grp"
  base_instance_name = "app-server"
  zone = "us-central1-a"
  version {
    name = "appserver"
    instance_template = google_compute_region_instance_template.app_server_templates.id
  }
  target_size = 2
}*/
resource "google_compute_disk" "app_server_vm_additional_disk" {
 name = "disk${count.index}"
 count = var.environment != "prod" ? 0 : "${length(local.prod_disk_helper)}"
 type = lookup((lookup(local.prod_disk_helper, "disk${count.index}")),"type")
 size = lookup((lookup(local.prod_disk_helper, "disk${count.index}")),"size")
 zone = lookup((lookup(local.prod_disk_helper, "disk${count.index}")),"zone")
}
output "at_disk_lst" {
  value = google_compute_disk.app_server_vm_additional_disk
}