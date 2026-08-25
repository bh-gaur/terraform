resource "aws_instance" "web_server" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  user_data = local.user_data

  tags = merge(local.common_tags, {
    Name = "WebServer-${count.index + 1}"
  })
}
