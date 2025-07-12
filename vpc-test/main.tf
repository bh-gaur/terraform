resource "aws_vpc" "my_vpc" {      #Create VPC
  cidr_block = var.cidr_block
  enable_dns_support   = true      #Allows instances to resolve domain names (like amazon.com or private AWS service endpoints).
  enable_dns_hostnames = true      #Instances with public IPs get a public DNS name like ec2-203-0-113-25.compute-1.amazonaws.com.


  tags = {
    name = var.aws_vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id            
  cidr_block = var.public_subnet_cidr_block
  map_public_ip_on_launch = true             #assign public ip address to instance that launched in this subnet
  availability_zone = var.availability_zone

  tags = {
    name = var.public_subnet_name
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    name = var.private_subnet_name
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    name = var.igw_name
  }
}

