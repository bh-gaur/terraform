terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
#   profile = "bhola-aws"
}

# Create IAM User
resource "aws_iam_user" "test_user" {
  name = "test"
}

# Attach IAM Policy (Allow User Management)
resource "aws_iam_policy" "user_policy" {
  name        = "IAMUserManagementPolicy"
  description = "Allow IAM user to create and manage access keys"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateAccessKey",
        "iam:ListAccessKeys",
        "iam:DeleteAccessKey",
        "iam:UpdateAccessKey"
      ],
      "Resource": "arn:aws:iam::*:user/${aws_iam_user.test_user.name}"
    }
  ]
}
EOF
}

# Attach Policy to User
resource "aws_iam_user_policy_attachment" "attach_user_policy" {
  user       = aws_iam_user.test_user.name
  policy_arn = aws_iam_policy.user_policy.arn
}

# Create Login Profile (AWS Console Access)
resource "aws_iam_user_login_profile" "user_login" {
  user    = aws_iam_user.test_user.name
  password_reset_required = true  # Force password reset
}

# Create Access & Secret Key (CLI Access)
resource "aws_iam_access_key" "test_user_key" {
  user = aws_iam_user.test_user.name
}

# Output Access Credentials (IMPORTANT: Store Securely!)
output "aws_access_key_id" {
  value     = aws_iam_access_key.test_user_key.id
  sensitive = true
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.test_user_key.secret
  sensitive = true
}