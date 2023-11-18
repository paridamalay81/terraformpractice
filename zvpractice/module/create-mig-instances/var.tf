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
