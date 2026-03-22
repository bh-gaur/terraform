################################################################################
# EKS Cluster Module - Outputs
# This file defines output values for the EKS cluster module
################################################################################

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "The security group ID of the cluster control plane"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "The name of the EKS node group"
  value       = aws_eks_node_group.eks_node_group.node_group_name
}

output "node_group_arn" {
  description = "The Amazon Resource Name (ARN) of the node group"
  value       = aws_eks_node_group.eks_node_group.arn
}

output "node_group_role_arn" {
  description = "The ARN of the IAM role for the node group"
  value       = aws_iam_role.eks_node_group_role.arn
}
