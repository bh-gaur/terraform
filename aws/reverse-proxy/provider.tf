# Define aws provider 
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
}


# provider "aws" {
#   region = "us-west-1"
#   access_key = "secrets.AWS_ACCESS_KEY_ID"     # Alternatively, use environment variables
#   secret_access_key = "your-secret-key"  # Alternatively, use environment variables
# }