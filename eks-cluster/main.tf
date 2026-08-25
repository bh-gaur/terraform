################################################################################
# EKS Cluster - Main Configuration
# This Terraform configuration creates a complete EKS cluster with VPC, IAM roles, and node groups
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
# AWS Provider Configuration
################################################################################

provider "aws" {
  region = var.aws_region
}

################################################################################
# Local Values
################################################################################

locals {
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
# VPC Module
################################################################################

module "vpc" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws
  }
  
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
  vpc_cidr     = var.vpc_cidr
  
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  map_public_ip       = var.map_public_ip
}

################################################################################
# EKS Cluster Module
################################################################################

module "eks_cluster" {
  source = "./modules/eks"
  
  providers = {
    aws = aws
  }
  
  cluster_name               = var.project_name
  project_name              = var.project_name
  environment               = var.environment
  tags                     = var.tags
  
  # Network configuration
  subnet_ids                = module.vpc.public_subnet_ids
  security_group_id          = module.vpc.security_group_id
  
  # Cluster configuration
  kubernetes_version          = var.kubernetes_version
  endpoint_private_access     = var.endpoint_private_access
  endpoint_public_access      = var.endpoint_public_access
  
  # Logging configuration
  enabled_cluster_log_types   = var.enabled_cluster_log_types
  
  # Node group configuration
  desired_size              = var.desired_size
  max_size                  = var.max_size
  min_size                  = var.min_size
  instance_type              = var.instance_type
  disk_size                 = var.disk_size
  ami_type                  = var.ami_type
  ssh_key_name              = var.ssh_key_name
  max_unavailable            = var.max_unavailable
  max_unavailable_percentage   = var.max_unavailable_percentage

  depends_on = [ module.vpc ]
}

################################################################################
# Key Pair for SSH Access
################################################################################

# resource "aws_key_pair" "eks_key" {
#   key_name   = var.ssh_key_name
#   public_key = var.ssh_public_key
  
#   tags = local.tags
# }




# resource "aws_iam_role" "eks_cluster_role" {
#   name = "eks-cluster-role"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
#   role       = aws_iam_role.eks_cluster_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }
# resource "aws_eks_cluster" "eks_cluster" {
#   name     = "eks-cluster"
#   role_arn = aws_iam_role.eks_cluster_role.arn
#   version = "1.35"
  
#   vpc_config {
#     subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
#   }
  
#   tags = {
#     Name = "eks-cluster"
#   }
  
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_cluster_policy,
#   ]
#   enabled_cluster_log_types = [
#     "api",               # API server logs
#     "audit",             # Security audit logs
#     "authenticator",     # Authentication logs
#     "controllerManager", # Controller manager logs
#     "scheduler"          # Scheduler logs
#   ]
# }
# ####
# # EKS Node Group IAM Role
# ####
# resource "aws_iam_role" "eks_node_group_role" {
#   name = "eks-node-group-role"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
#   role       = aws_iam_role.eks_node_group_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }
# resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
#   role       = aws_iam_role.eks_node_group_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }
# resource "aws_iam_role_policy_attachment" "eks_ecr_readonly_policy" {
#   role       = aws_iam_role.eks_node_group_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }
# ####
# # EKS Node Group
# ####
# resource "aws_eks_node_group" "eks_node_group" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "eks-node-group"
#   node_role_arn   = aws_iam_role.eks_node_group_role.arn
#   subnet_ids      = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  
#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }
  
#   instance_types = ["t2.small"]
  
#   remote_access {
#     ec2_ssh_key = var.key_name
#     source_security_group_ids = [aws_security_group.eks_sg.id]
#   }
  
#   update_config {
#     max_unavailable = 1
#   }
  
#   tags = {
#     Name = "eks-node-group"
#   }
  
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_node_group_policy,
#     aws_iam_role_policy_attachment.eks_cni_policy,
#     aws_iam_role_policy_attachment.eks_ecr_readonly_policy,
#   ]
# }
