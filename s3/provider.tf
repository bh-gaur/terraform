provider "aws" {
  region = "us-east-1"
}

provider "awscc" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.0.0"
    }
    awscc = {
      source = "hashicorp/awscc"
      version = "1.0.0"
    }
  }
}
