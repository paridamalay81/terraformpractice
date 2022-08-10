variable "instance_name" {
  type = list(string)
  default = [ "MGOWICLMQ3","JFBWICLMQ4" ]
}
variable "instance_zone" {
  type = string
  validation {
    condition=substr(var.instance_name,0,3)=="mgo"
    value="us-east1-a"
  }
  validation {
    condition=substr(var.instance_name,0,3)=="jfb"
    value="us-east1-c"
  }
}