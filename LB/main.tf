provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.92.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create an Internet Gateway (IGW)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Create a Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "subnet_a_assoc" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_b_assoc" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Define security group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "loadbalancer-sg"
  description = "Allow inbound traffic on port 80"
  vpc_id      = aws_vpc.main.id

  # Allow SSH (Port 22) from anywhere (Modify as needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from all IPs (change for better security)
  }

  # Allow HTTP (Port 80) for Web Traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from all IPs
  }

  # Allow HTTPS (Port 443) for Secure Web Traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS from all IPs
  }

  # Allow All Outbound Traffic (Necessary for Internet access)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer-sg"
  }
}

# Create EC2 Instances
resource "aws_instance" "web_server_1" {
  ami                    = "ami-084568db4383264d4"  # Update with a valid AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id  # Reference to a subnet
  vpc_security_group_ids = [aws_security_group.lb_sg.id]
  key_name               = "bhola-ubuntu"

  # User Data to install Nginx
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

  tags = {
    Name = "WebServer1"
  }
}

resource "aws_instance" "web_server_2" {
  ami                    = "ami-084568db4383264d4"  # Update with a valid AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_b.id  # Reference to another subnet
  vpc_security_group_ids = [aws_security_group.lb_sg.id]
  key_name               = "bhola-ubuntu"

  # User Data to install Nginx
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

  tags = {
    Name = "WebServer2"
  }
}

# Create a Target Group for the Load Balancer
resource "aws_lb_target_group" "tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"  # Health check URL for the targets
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach_instance_1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_server_1.id  # Attach first instance
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach_instance_2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_server_2.id  # Attach second instance
  port             = 80
}

# Create the Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}



output "WebServer1_public_ip" {
  value = aws_instance.web_server_1.public_ip
}

output "WebServer2_public_ip" {
  value = aws_instance.web_server_2.public_ip
}

output "load_balancer" {
  value = aws_lb.app_lb.dns_name
}