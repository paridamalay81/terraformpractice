variable "environment" {
  type = string
  default = "prod"
}
variable "machine_type" {
  type = map(string)
  default = {
    "prod" = "e2-medium"
    "dev"  = "e2-small"
  }
}
variable "disk_prod" {
  type = map(any)
  default = {
    disk1 = ["pd-ssd","80","us-central1-a"]
    disk2 = ["pd-ssd","180","us-central1-a"]
  }  
}