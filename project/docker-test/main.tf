#Create Security Group
resource "aws_security_group" "allow_ports" {
  name        = "my-first-project-sg"
  description = "Security group allowing SSH, HTTP, HTTPS, and custom application ports"
  vpc_id      = var.vpc_id  # Replace with your VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (or restrict as needed)
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (or restrict as needed)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (or restrict as needed)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (or restrict as needed)
  }

  # Optionally, you can add egress rules if needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH_HTTP_HTTPS_SG"
  }
}

# Create EC2 machine 
resource "aws_instance" "example_instance" {
    # count = var.num                 # how many instance will create
    ami = var.ami_id                  # ami_id for instance
    instance_type = var.instance_type # instance type 
    key_name = var.key_name           # attach key pair to instance
    security_groups = [aws_security_group.allow_ports.name]  # attach security group to instance

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

                # Update package lists
                sudo apt-get update -y
                # Install required dependencies
                sudo apt-get install -y \
                    ca-certificates \
                    curl \
                    gnupg
                # Create the directory for Docker's GPG key if it doesn't exist
                sudo install -m 0755 -d /etc/apt/keyrings
                # Download and add Docker's official GPG key
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
                sudo chmod a+r /etc/apt/keyrings/docker.asc
                # Add Docker repository to sources list
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                # Update package lists again
                sudo apt-get update -y
                # Install Docker
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                # Start and enable Docker service
                sudo systemctl enable --now docker
                # Add 'ubuntu' user to the docker group to allow non-root usage (optional)
                sudo usermod -aG docker ubuntu
                # Verify installation (optional)
                sudo docker --version
                
                sudo docker pull bgdevopslearn/test:latest
                sudo docker run -d -p 3000:3000 bgdevopslearn/test
                EOF

}