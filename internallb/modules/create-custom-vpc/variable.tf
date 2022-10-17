variable "environment" {
    type = string
    default = "dev"
}
variable "subnets" {
  type = map
  default = {
    "dev-us-east1" = "10.0.1.0/28"
    "dev-us-central" = "10.0.2.0/28"
    "prod-us-east1" = "10.0.3.0/28"
    "prod-us-central1" = "10.0.4.0/28"
  }
}
variable "spec_region" {
  type = string
  validation {
    condition = ! (var.spec_region == "us-east1" ||  var.spec_region == "us-central1")
    error_message = "Region should be us-east1/us-central1"
  }
}