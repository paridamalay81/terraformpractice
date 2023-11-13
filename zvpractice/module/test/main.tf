variable "disk_prod_tst" {
  type = map(any)
  default = {
    disk1 = ["pd-ssd","80","us-central1-a"]
    disk2 = ["pd-ssd","180","us-central1-a"]
  }  
}
locals {
  local-disk={for disk,prop-list in var.disk_prod_tst:upper(disk)=> disk}
}
output "disk_prod" {
  value = local.local-disk
}