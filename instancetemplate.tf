data "google_compute_image" "my_image" {
  family  = var.os_family
}
resource "google_compute_instance_template" "test-tempalte-terraform" {
  name = "test-template"
  region = var.region
  tags = "test-instance-tf"
  machine_type = "e2-micro"
  disk {
    boot = true
    source_image = data.google_compute_image.my_image.self_link
  }
}
resource "google_compute_instance_from_template" "instance_from_template" {
  name = "instance-from-template"  
  source_instance_template = google_compute_instance_template.test-tempalte-terraform.id
}