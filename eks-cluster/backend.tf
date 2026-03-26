terraform {
  backend "s3" {
    bucket = "my-tterraform-state-buckettt"
    key    = "eks-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}