variable "environment" {
  type = string
  default = "dev"
  description = "Need to Enter dev or prod environment"
}
variable "vm-instance-number" {
  default = var.environment == "dev" ? 1 : 3  
}