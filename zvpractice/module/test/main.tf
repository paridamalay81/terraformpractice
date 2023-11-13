variable "disk_prod_tst" {
  type = map(any)
  default = {
    disk1 = ["pd-ssd","80","us-central1-a"]
    disk2 = ["pd-ssd","180","us-central1-a"]
  }  
}
variable "prod-test-types" {
  type = list
  default = ["disk-type","disk-size","zone"]
}
locals {
  local-disk={
    for disk,disk-prop-list in var.disk_prod_tst:disk=>zipmap(var.prod-test-types,disk-prop-list)           
}
}
output "disk_prod" {
  value = local.local-disk
}