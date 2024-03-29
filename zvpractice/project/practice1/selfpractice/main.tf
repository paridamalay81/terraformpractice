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
resource "google_compute_disk" "compute_disk"{
  count = local.disk_count
  name = "compute-disk${count.index}"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size = 60
}
  output "cdisk" {
  value=google_compute_disk.compute_disk
}

resource "google_compute_instance" "instance_web" {
  name = "test-temp-instance"
  machine_type = "n2-standard-2"
  zone  = "us-central1-a"
  network_interface {
    network = "default"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }
  dynamic "attached_disk" {
    for_each = [for disk in google_compute_disk.compute_disk:disk]
    content {
      source = attached_disk.value.self_link     
    }    
  }
}
