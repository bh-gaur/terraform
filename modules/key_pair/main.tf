# Module for creating an AWS key pair


provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = var.public_key
  
  tags = {
    Name = var.key_name
  }
}