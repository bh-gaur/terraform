################################################################################
# EKS Cluster Module - Main Configuration
# This module creates a complete Amazon EKS (Elastic Kubernetes Service) cluster
# with all necessary IAM roles, node groups, and networking components
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
  cluster_name = var.cluster_name
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
# IAM Role for EKS Cluster
################################################################################

resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.cluster_name}-cluster-role"
  
  # Policy that allows EKS service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# Attach AWS managed EKS cluster policy
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

################################################################################
# EKS Cluster
################################################################################

resource "aws_eks_cluster" "eks_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version
  
  # Network configuration
  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }
  
  # Logging configuration for monitoring and debugging
  enabled_cluster_log_types = var.enabled_cluster_log_types
  
  # Encryption configuration for data security
  dynamic "encryption_config" {
    for_each = var.kms_key_arn != "" ? [1] : []
    content {
      resources = var.encryption_resources
      provider {
        key_arn = var.kms_key_arn
      }
    }
  }
  
  tags = local.tags
  
  # Ensure IAM policy is attached before cluster creation
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

################################################################################
# IAM Role for EKS Node Group
################################################################################

resource "aws_iam_role" "eks_node_group_role" {
  name = "${local.cluster_name}-node-group-role"
  
  # Policy that allows EC2 service to assume this role for worker nodes
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# Attach AWS managed policies for node group permissions
resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach CNI policy for pod networking
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach ECR policy for container image access
resource "aws_iam_role_policy_attachment" "eks_ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_custom_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

################################################################################
# EKS Addons
################################################################################

# CoreDNS - Core DNS service for Kubernetes
resource "aws_eks_addon" "coredns" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "coredns"
  addon_version            = var.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.coredns_role.arn
  
  tags = local.tags
}

# kube-proxy - Network proxy for Kubernetes services
resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "kube-proxy"
  addon_version            = var.kube_proxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.kube_proxy_role.arn
  
  tags = local.tags
}

# VPC CNI - Amazon VPC CNI plugin for Kubernetes networking
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.vpc_cni_role.arn
  
  tags = local.tags
}

# AWS EBS CSI Driver - Persistent storage with EBS volumes
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
  
  tags = local.tags
}

################################################################################
# IAM Roles for EKS Addons
################################################################################

# IAM role for CoreDNS addon
resource "aws_iam_role" "coredns_role" {
  name = "${local.cluster_name}-coredns-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "coredns_policy" {
  role       = aws_iam_role.coredns_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# IAM role for kube-proxy addon
resource "aws_iam_role" "kube_proxy_role" {
  name = "${local.cluster_name}-kube-proxy-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "kube_proxy_policy" {
  role       = aws_iam_role.kube_proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# IAM role for VPC CNI addon
resource "aws_iam_role" "vpc_cni_role" {
  name = "${local.cluster_name}-vpc-cni-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "vpc_cni_policy" {
  role       = aws_iam_role.vpc_cni_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# IAM role for EBS CSI Driver addon
resource "aws_iam_role" "ebs_csi_role" {
  name = "${local.cluster_name}-ebs-csi-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################################################################
# EKS Node Group
################################################################################

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids
  
  # Auto-scaling configuration
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  
  # Instance configuration
  instance_types = [var.instance_type]
  disk_size      = var.disk_size
  ami_type        = var.ami_type
  
  # Remote access configuration
  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [var.security_group_id]
  }
  
  # Update configuration for rolling updates
  update_config {
    max_unavailable_percentage = var.max_unavailable_percentage
  }
  
  # Tags for node group resources
  tags = local.tags
  
  # Ensure all IAM policies are attached before node group creation
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly_policy,
    aws_iam_role_policy_attachment.eks_node_group_custom_policy,
  ]
}
