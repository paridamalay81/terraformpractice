#Variables for creating AS2 instances

/* Neeed to pass the instance names to create as ["instance1","instance2"] for creating first and second instance in GCP 
       and CVO mount will be attached to the first instance only. */
variable instance_list {
  type = list(string)
}
variable "machine_type" {
  type = string
  default = "n2-highmem-4"
}
variable "vm_source_image" {
  type = string
  default = "Need to enter"
}
variable "vm_source_image3" {
  type = string
  default = "Need to enter"
}
#Variables for creating AS2 instances