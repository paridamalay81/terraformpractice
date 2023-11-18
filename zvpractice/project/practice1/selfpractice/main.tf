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
    disk_attributes={
        for m,v in local.disk_prod:a=>v
    }
}
output "disk_attr_map" {
  value = local.disk_attributes
}