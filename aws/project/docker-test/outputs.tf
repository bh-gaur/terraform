output "public_ip" {
  value = aws_instance.example_instance.public_ip  # get public_ip
}

output "ami_id" {
  value = aws_instance.example_instance.ami  # get ami_id
}

# output "instance_tags" {
#   value = aws_instance.example_instance.tags  # get instance_name
# }