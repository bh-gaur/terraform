resource "aws_instance" "ec2_instance" {
    count = var.instance_count  
    ami = "${var.ami_id}"
    instance_type = "t2.micro"
    key_name = "bh-gaur.key"
    security_groups = ["default"]
    public_ip = true

    

    tags = {
      Name = "Terraform-EC2-Instance"
    }

    user_data = <<-EOF
              #!/bin/bash

              # Update package list first
              apt update

              EOF
}