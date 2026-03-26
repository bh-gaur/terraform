resource "aws_vpc" "my-vpc" {
    cidr_block = var.aws_vpc-cidr_block


    tags = {
      Name = "my-vpc"
    }
  
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my-vpc.id

    tags = {
      Name = "my_igw"
    }
  
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.aws_subnet-cidr_block
    availability_zone = var.public-subnet

    tags = {
      Name = "my-subnet"
    }

}

resource "aws_route_table" "my-rt" {
    vpc_id = aws_vpc.my-vpc.id

    tags = {
    Name = "my-rt"
  }
}

resource "aws_route_table_association" "myroute-table-association" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.my-rt.id
  
}

resource "aws_route" "public-subnet-route" {
    route_table_id = aws_route_table.my-rt.id
    gateway_id = aws_internet_gateway.my_igw.id
    destination_cidr_block = "0.0.0.0/0"
    
  
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from any IP address. For production, restrict this to your specific IP or IP range.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to any destination
  }

  vpc_id = aws_vpc.my-vpc.id

  tags = {
    name = "my-sg"
  }
}




resource "aws_instance" "test" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public-subnet.id
    associate_public_ip_address = true
    key_name = var.key_name

     vpc_security_group_ids = [
       aws_security_group.ssh_access.id
     ]

    tags = {
      Name = var.instance_name
  }
}
