resource "aws_security_group" "my_sg" {
  name = "bhola_sg"
  description = "Creating security groups for inbound and outbound traffic"

  tags = {
    name = "test"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
  
  ingress = {
    protocol = -1 
    self     =  true
  }
}
