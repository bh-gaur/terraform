variable "instance_count" {
    description = "Number of EC2 instances to create"
    type        = number
    default     = 1
  
}

variable "ami_id" {
    description = "The AMI ID for the EC2 instance"
    type        = string
    default     = "ami-04b4f1a9cf54c11d0"
}