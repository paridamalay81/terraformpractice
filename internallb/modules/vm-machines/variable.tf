variable "environment" {
  type = string
  default = "dev"
  description = "Need to Enter dev or prod environment"
}
variable "vm-instance-number" {
  value = var.environment == "dev" ? 1 : 3  
}