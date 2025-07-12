terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.19.0"
# }