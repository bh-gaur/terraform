provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

############################################
## Developer Role 
############################################

resource "aws_iam_policy" "developer_policy" {
  name        = "developer-policy"
  description = "Developer policy with S3 Read, CloudWatch Read, and NO IAM Access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Read-Only S3 Access
      {
        Sid      = "AllowS3ReadAccess"
        Effect   = "Allow"
        Action   = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = "*"
      },
      # 2. Read-Only CloudWatch & Logs Access
      {
        Sid      = "AllowCloudWatchReadAccess"
        Effect   = "Allow"
        Action   = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "logs:Describe*",
          "logs:Get*",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      },
      # 3. Explicit Deny for all IAM Access
      {
        Sid      = "DenyIAMAccess"
        Effect   = "Deny"
        Action   = "iam:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "developer" {
    name = "developer"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "developer_policy_attachment" {
    role = aws_iam_role.developer.name
    policy_arn = aws_iam_policy.developer_policy.arn
}

#####################################################
## DevOps Role 
#####################################################

resource "aws_iam_policy" "devops_policy" {
  name        = "devops-policy"
  description = "DevOps policy with S3, CloudWatch , and NO User management permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Read-Only S3 Access
      {
        Sid      = "AllowS3FullAccess"
        Effect   = "Allow"
        Action   = [
          "s3:*"
        ]
        Resource = "*"
      },
      # 2. Read-Only CloudWatch & Logs Access
      {
        Sid      = "AllowCloudWatchFullAccess"  
        Effect   = "Allow"
        Action   = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      },
      # 3. Explicit Deny for all IAM Access
      {
        Sid      = "AllowIAMPassRole"
        Effect   = "Allow"
        Action   = [
            "iam:PassRole"
        ]
        Resource = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    ]
  })
}

resource "aws_iam_role" "devops" {
    name = "devops"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "devops_policy_attachment" {
    role = aws_iam_role.devops.name
    policy_arn = aws_iam_policy.devops_policy.arn
}

