# Create EC2 instance with user data to install Nginx

resource "aws_instance" "my_instance" {
    count = var.num                 # how many instance will create
    ami = var.ami_id                  # ami_id for instance
    instance_type = var.instance_type # instance type 
    key_name = var.key_name           # attach key pair to instance
    security_groups = [var.security_groups]

    tags = {
      Name = var.name                 # instance name 
    }

    user_data = <<-EOF
              #!/bin/bash

              # Update package list first
              apt update

              # Install dependencies for adding Nginx repository
              apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

              # Add Nginx signing key
              curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

              # Import the key for verification
              gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

              # Add the Nginx repository
              echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list

              # Pin Nginx packages to the Nginx origin
              echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx

              # Update package list again after adding new repo
              apt update

              # Install Nginx
              apt install -y nginx

              # Check nginx version
              nginx -v

              # Start and enable nginx
              systemctl start nginx
              systemctl enable nginx

              # Verify nginx service status
              systemctl status nginx


              EOF

}