################################################################################
# VPC Module - Main Configuration
# This module creates a Virtual Private Cloud (VPC) with public and private subnets
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

################################################################################
# Local Values
################################################################################

locals {
  vpc_cidr = var.vpc_cidr
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
}

################################################################################
# Data Sources
################################################################################

# Get the current AWS region
data "aws_region" "current" {}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-vpc"
  })
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-igw"
  })
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone        = data.aws_region.current.name + "a"
  map_public_ip_on_launch = var.map_public_ip
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-public-subnet-a"
    Type = "Public"
  })
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone        = data.aws_region.current.name + "b"
  map_public_ip_on_launch = var.map_public_ip
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-public-subnet-b"
    Type = "Public"
  })
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone        = data.aws_region.current.name + "a"
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-private-subnet-a"
    Type = "Private"
  })
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone        = data.aws_region.current.name + "b"
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-private-subnet-b"
    Type = "Private"
  })
}

################################################################################
# Route Tables
################################################################################

# Public route table for internet access
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-public-rt"
  })
}

# Route for internet gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public.id
}

# Private route tables for internal routing
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-private-rt-a"
  })
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-private-rt-b"
  })
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_b.id
}

################################################################################
# Elastic IP for NAT Gateway
################################################################################

resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-nat-eip"
  })
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_a.id
  
  tags = merge(local.tags, {
    Name = "${var.project_name}-nat"
  })
}

################################################################################
# Default Route for Private Subnets
################################################################################

# Route private subnet A through NAT gateway
resource "aws_route" "private_a_nat" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Route private subnet B through NAT gateway
resource "aws_route" "private_b_nat" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

################################################################################
# VPC Security Group
################################################################################

resource "aws_security_group" "main" {
  name        = "${var.project_name}-security-group"
  description = "Main security group for VPC"
  vpc_id      = aws_vpc.main.id
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }
  
  tags = local.tags
}

################################################################################
# Outputs
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "security_group_id" {
  description = "The ID of the main security group"
  value       = aws_security_group.main.id
}
