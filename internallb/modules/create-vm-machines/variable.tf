#for variables
variable "instance_name" {
  type = list(string)
}
variable "instance_zone" {
  type = map
  default = {
    1 = "us-east1"
    2 = "us-central1"
  }
}