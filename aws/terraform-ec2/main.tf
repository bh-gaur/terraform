provider "aws" {
  region = var.region
}

module "ec2" {
  source = "./modules/ec2"

  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = var.subnet_id
  key_name           = var.key_name
  security_group_ids = var.security_group_ids
  instance_name      = "test-ec2"
}