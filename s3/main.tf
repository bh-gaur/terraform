provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "my-testing-bucket"
  provider = aws.us-east-1
  tags = {
    Name = "test"
  }
}