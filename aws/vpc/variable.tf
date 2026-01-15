variable "ami_id" {
    description = "ami_id for instances"
    type = string
    default = "ami-0fc5d935ebf8bc3bc"  
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "instance_name" {
    type = string
    default = "test"
}

variable "aws_vpc-cidr_block" {
    type = string
    default = "192.168.0.0/16"
}

variable "public-subnet" {
    type = string
    default = "us-east-1a"
}

variable "aws_subnet-cidr_block" {
    type = string
    default = "192.168.1.0/24"
}

variable "key_name" {
    type = string
    default = "first"
}
