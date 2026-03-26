terraform {
  backend "s3" {
    bucket = "my-tterraform-state-buckettt"
    key    = "ec2/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}