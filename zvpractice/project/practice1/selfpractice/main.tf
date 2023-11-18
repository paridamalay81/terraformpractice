provider "google" {
  project     = "wise-shell-330415"
  region      = "us-central1"
}
variable "var_env" {
  type = map(any)
  default = {
    prod=2
    dev=1
  }
}
locals{
    env="prod"
    disk_count=local.env=="prod"?lookup(var.var_env,local.env):lookup(var.var_env,local.env)
}
output "diskcount" {
  value=local.disk_count
}