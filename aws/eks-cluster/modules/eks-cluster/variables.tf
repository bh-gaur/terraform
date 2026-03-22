################################################################################
# EKS Cluster Module - Variables
# This file defines input variables for the EKS cluster module
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

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

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "subnet_ids" {
  description = "List of subnet IDs where EKS cluster will be deployed"
  type        = list(string)
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
  default     = "AL2_x86_64"
}

variable "ssh_key_name" {
  description = "Name of EC2 key pair for SSH access"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for worker nodes"
  type        = string
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
