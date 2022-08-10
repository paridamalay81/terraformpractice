resource "google_compute_instance" "instance_vm_machines" {
    count = length(var.instance_name)
    name = var.instance_name[count]
    zone = substr(var.instance_name,0,3)=="mgo"?"us-east1-a":"us-east1-c"
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