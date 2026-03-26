####################################
# Variables for VPC Configuration
####################################

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "bhola-aws"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "networking-vpc"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "networking"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "nat_eip_name" {
  description = "Name tag for the NAT Elastic IP"
  type        = string
  default     = "nat-eip"
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway"
  type        = string
  default     = "nat-gw"
}

variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
  default     = "igw"
}

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
  default     = "public-rt"
}

variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
  default     = "private-rt"
}

variable "public_subnet_names" {
  description = "Name tags for public subnets"
  type        = list(string)
  default     = ["public-subnet-a", "public-subnet-b"]
}

variable "private_subnet_names" {
  description = "Name tags for private subnets"
  type        = list(string)
  default     = ["private-subnet-a", "private-subnet-b"]
}

variable "allow_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allow_http_cidr" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allow_https_cidr" {
  description = "CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
  default     = "bhola-ubuntu"
}

################################################################################
# EKS Cluster - Variables
# This file defines input variables for the EKS cluster configuration
################################################################################

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}



variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "map_public_ip" {
  description = "Map public IP on launch for public subnets"
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "Name of EC2 key pair for SSH access"
  type        = string
  default     = "bhola-ubuntu"
}

variable "ssh_public_key" {
  description = "Public SSH key for EC2 instances"
  type        = string
  default     = "bhola-ubuntu"
}

variable "endpoint_private_access" {
  description = "Whether the EKS API server endpoint is private"
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Whether the EKS API server endpoint is public"
  type        = bool
  default     = true
}

variable "enabled_cluster_log_types" {
  description = "List of cluster log types to enable"
  type        = list(string)
  default     = [
    "api",               # API server logs
    "audit",             # Security audit logs
    "authenticator",     # Authentication logs
    "controllerManager", # Controller manager logs
    "scheduler"          # Scheduler logs
  ]
}

variable "encryption_resources" {
  description = "List of resources to encrypt in the cluster"
  type        = list(string)
  default     = [
    "secrets"            # Encrypt Kubernetes secrets
  ]
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t2.small"
}

variable "disk_size" {
  description = "Disk size for worker nodes in GB"
  type        = number
  default     = 20
}

variable "ami_type" {
  description = "AMI type for worker nodes"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "max_unavailable" {
  description = "Maximum number of unavailable nodes during updates"
  type        = number
  default     = 1
}

variable "max_unavailable_percentage" {
  description = "Maximum percentage of unavailable nodes during updates"
  type        = number
  default     = 33
}

variable "kms_key_arn" {
  description = "KMS key ARN for EKS cluster encryption"
  type        = string
  default     = ""
}
