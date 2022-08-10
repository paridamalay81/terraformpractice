resource "google_compute_instance" "instance_vm_machines" {
    count = length(var.instance_name)
    name = var.instance_name
    zone = var.instance_zone
    machine_type = "e2-medium"
    
    tags = ["webserver"]

    boot_disk {
     initialize_params {
       image = "centos-7-v20220303"
        }
     }
     network_interface {
      network = "default"
     access_config {
      
        }
     }
     metadata_startup_script = <<-EOF
         #!/bin/bash
        sudo yum update httpd
        sudo yum install httpd -y
         sudo systemctl start httpd
        echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
         EOF
  
    }