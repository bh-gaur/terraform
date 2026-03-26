# EKS Cluster Terraform Module

A comprehensive Terraform module for deploying Amazon EKS (Elastic Kubernetes Service) clusters with all necessary components including VPC, IAM roles, node groups, and essential addons.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Usage](#usage)
- [Configuration](#configuration)
- [EKS Addons](#eks-addons)
- [Examples](#examples)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This module creates a production-ready EKS cluster with:
- Complete VPC infrastructure
- IAM roles and policies
- Managed node groups
- Essential Kubernetes addons
- Security best practices
- Monitoring and logging

## ✨ Features

### 🏗️ Infrastructure Components
- **VPC**: Public and private subnets across multiple AZs
- **Security Groups**: Properly configured for EKS control plane and worker nodes
- **Internet Gateway & NAT**: For public and private subnet connectivity
- **Route Tables**: Optimized routing for network traffic

### 🔐 Security & IAM
- **EKS Cluster Role**: IAM role for EKS service
- **Node Group Role**: IAM role for worker nodes with appropriate policies
- **Addon Roles**: Dedicated IAM roles for each EKS addon
- **Least Privilege**: Following AWS security best practices

### 🚀 Kubernetes Components
- **EKS Cluster**: Latest Kubernetes version support
- **Managed Node Groups**: Auto-scaling worker nodes
- **EKS Addons**: CoreDNS, kube-proxy, VPC CNI, EBS CSI Driver
- **Logging**: Comprehensive cluster logging enabled

### 📊 Monitoring & Observability
- **Cluster Logs**: API server, audit, authenticator, controller manager, scheduler
- **Resource Tags**: Consistent tagging across all resources
- **Health Checks**: Built-in cluster and node group health monitoring

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        EKS Cluster                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │   Control Plane │    │         Node Groups            │ │
│  │                 │    │                                 │ │
│  │ • API Server    │    │ • Worker Nodes                 │ │
│  │ • etcd          │    │ • Auto-scaling                 │ │
│  │ • Scheduler     │    │ • Managed Updates              │ │
│  └─────────────────┘    └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                           VPC                                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Public Subnets                          │ │
│  │  • EKS Control Plane Endpoint                          │ │
│  │  • NAT Gateway                                         │ │
│  │  • Internet Gateway                                    │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Private Subnets                         │ │
│  │  • Worker Nodes                                        │ │
│  │  • Database Subnets (optional)                         │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Usage

### Basic Usage

```hcl
module "eks_cluster" {
  source = "./modules/eks"
  
  # Required
  cluster_name    = "my-production-cluster"
  project_name    = "my-app"
  subnet_ids      = module.vpc.public_subnet_ids
  ssh_key_name    = "my-ssh-key"
  security_group_id = module.vpc.security_group_id
  
  # Optional
  environment     = "production"
  kubernetes_version = "1.29"
  
  tags = {
    Team = "platform"
    CostCenter = "engineering"
  }
}
```

### Complete Example

```hcl
provider "aws" {
  region = "us-east-1"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name = "my-app"
  environment  = "production"
  
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

# EKS Cluster Module
module "eks_cluster" {
  source = "./modules/eks"
  
  # Cluster Configuration
  cluster_name    = "my-production-cluster"
  project_name    = "my-app"
  environment     = "production"
  kubernetes_version = "1.29"
  
  # Network
  subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.vpc.security_group_id
  
  # Node Group
  desired_size = 2
  max_size     = 4
  min_size     = 1
  instance_type = "t3.medium"
  disk_size    = 50
  ssh_key_name = "my-ssh-key"
  
  # Access
  endpoint_private_access = true
  endpoint_public_access  = false
  
  # Addon Versions
  coredns_version    = "v1.11.1-eksbuild.6"
  kube_proxy_version = "v1.28.8-eksbuild.2"
  vpc_cni_version    = "v1.18.1-eksbuild.1"
  ebs_csi_version    = "v1.28.0-eksbuild.1"
  
  tags = {
    Team = "platform"
    Environment = "production"
    Project = "my-app"
  }
}
```

## ⚙️ Configuration

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `cluster_name` | Name of the EKS cluster | `string` |
| `project_name` | Name of the project | `string` |
| `subnet_ids` | List of subnet IDs for EKS cluster | `list(string)` |
| `ssh_key_name` | Name of EC2 key pair for SSH access | `string` |
| `security_group_id` | Security group ID for worker nodes | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `environment` | Environment (dev, staging, prod) | `string` | `"dev"` |
| `kubernetes_version` | Kubernetes version | `string` | `"1.35"` |
| `desired_size` | Desired number of worker nodes | `number` | `1` |
| `max_size` | Maximum number of worker nodes | `number` | `2` |
| `min_size` | Minimum number of worker nodes | `number` | `1` |
| `instance_type` | EC2 instance type for workers | `string` | `"t2.small"` |
| `disk_size` | Disk size for worker nodes (GB) | `number` | `20` |
| `ami_type` | AMI type for worker nodes | `string` | `"AL2_x86_64"` |
| `endpoint_private_access` | Private API server endpoint | `bool` | `false` |
| `endpoint_public_access` | Public API server endpoint | `bool` | `true` |

### Addon Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `coredns_version` | CoreDNS addon version | `string` | `"v1.11.1-eksbuild.6"` |
| `kube_proxy_version` | kube-proxy addon version | `string` | `"v1.28.8-eksbuild.2"` |
| `vpc_cni_version` | VPC CNI addon version | `string` | `"v1.18.1-eksbuild.1"` |
| `ebs_csi_version` | EBS CSI Driver version | `string` | `"v1.28.0-eksbuild.1"` |

## 🧩 EKS Addons

This module includes the following essential EKS addons:

### CoreDNS
- **Purpose**: DNS service for Kubernetes
- **Usage**: Service discovery within the cluster
- **IAM Role**: `${cluster_name}-coredns-role`

### kube-proxy
- **Purpose**: Network proxy for Kubernetes services
- **Usage**: Handles network routing and load balancing
- **IAM Role**: `${cluster_name}-kube-proxy-role`

### VPC CNI
- **Purpose**: Amazon VPC CNI plugin for networking
- **Usage**: Enables pod communication using AWS VPC
- **IAM Role**: `${cluster_name}-vpc-cni-role`

### AWS EBS CSI Driver
- **Purpose**: Persistent storage with EBS volumes
- **Usage**: Allows pods to use EBS volumes for persistent storage
- **IAM Role**: `${cluster_name}-ebs-csi-role`

### Managing Addons

#### List Addons
```bash
aws eks list-addons --cluster-name <cluster-name>
```

#### Update Addon
```bash
aws eks update-addon --cluster-name <cluster-name> --addon-name coredns --addon-version v1.11.1-eksbuild.6
```

#### Delete Addon
```bash
aws eks delete-addon --cluster-name <cluster-name> --addon-name coredns
```

## 📚 Examples

### Example 1: Development Cluster
```hcl
module "dev_cluster" {
  source = "./modules/eks"
  
  cluster_name = "dev-cluster"
  project_name = "my-app"
  subnet_ids = module.vpc.public_subnet_ids
  ssh_key_name = "dev-key"
  security_group_id = module.vpc.security_group_id
  
  # Small dev cluster
  desired_size = 1
  max_size     = 2
  min_size     = 1
  instance_type = "t3.small"
  
  environment = "development"
  endpoint_public_access = true
}
```

### Example 2: Production Cluster
```hcl
module "prod_cluster" {
  source = "./modules/eks"
  
  cluster_name = "prod-cluster"
  project_name = "my-app"
  subnet_ids = module.vpc.private_subnet_ids
  ssh_key_name = "prod-key"
  security_group_id = module.vpc.security_group_id
  
  # Larger production cluster
  desired_size = 3
  max_size     = 6
  min_size     = 2
  instance_type = "t3.medium"
  disk_size    = 100
  
  environment = "production"
  endpoint_private_access = true
  endpoint_public_access = false
  
  # Enable all logging
  enabled_cluster_log_types = [
    "api",
    "audit", 
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}
```

### Example 3: Cluster with Custom Addons
```hcl
module "custom_cluster" {
  source = "./modules/eks"
  
  # ... basic configuration ...
  
  # Custom addon versions
  coredns_version = "v1.11.1-eksbuild.6"
  kube_proxy_version = "v1.28.8-eksbuild.2"
  vpc_cni_version = "v1.18.1-eksbuild.1"
  ebs_csi_version = "v1.28.0-eksbuild.1"
  
  # Additional configuration
  kms_key_arn = aws_kms_key.eks.arn
}
```

## 🔧 Requirements

| Tool | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS Provider | ~> 5.0 |
| kubectl | >= 1.20 |
| AWS CLI | >= 2.0 |

## 📝 Notes

### Security Considerations
- The module creates IAM roles with least privilege access
- Security groups restrict traffic to necessary ports only
- Consider using private endpoints for production clusters
- Enable encryption for sensitive data using KMS

### Cost Optimization
- Use appropriate instance types for your workload
- Consider spot instances for non-critical workloads
- Monitor and adjust cluster size based on usage
- Enable cluster autoscaler for dynamic scaling

### Best Practices
- Use separate clusters for different environments
- Implement proper tagging for cost allocation
- Regularly update Kubernetes versions
- Backup critical data and configurations
- Monitor cluster health and performance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
- Create an issue in the repository
- Check the [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- Review the [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 📊 Outputs

| Name | Description |
|------|-------------|
| `cluster_name` | The name of the EKS cluster |
| `cluster_arn` | The Amazon Resource Name (ARN) of the cluster |
| `cluster_endpoint` | The endpoint for the EKS cluster |
| `cluster_certificate_authority_data` | The certificate authority data for the cluster |
| `cluster_security_group_id` | The security group ID of the cluster control plane |
| `node_group_name` | The name of the EKS node group |
| `node_group_arn` | The Amazon Resource Name (ARN) of the node group |
| `node_group_role_arn` | The ARN of the IAM role for the node group |

### Example Usage of Outputs

```hcl
output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubeconfig file content"
  value       = module.eks_cluster.kubeconfig
  sensitive   = true
}
```

---

**Happy Kubernetes-ing! 🎉**
