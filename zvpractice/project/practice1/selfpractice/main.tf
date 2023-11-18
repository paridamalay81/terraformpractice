provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
locals {  
  disk_prod = {   
    disk1 = ["pd-ssd","80","us-central1-a"]
    disk2 = ["pd-ssd","180","us-central1-a"]
  }
  disk_prod_attr = ["type","size","zone"] 
  prod_disk_helper={    
    for disk,disk_attr in local.disk_prod:disk=>zipmap(local.disk_prod_attr,disk_attr)    
  }
}
output "disk_attr_map" {
  value = local.prod_disk_helper
}