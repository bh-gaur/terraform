variable "num" {
    description = "number of instances"
    type = number
    default = 1
}

variable "ami_id" {
    description = "ami id of instance"
    type = string
    default = "ami-04b4f1a9cf54c11d0"
}

variable "instance_type" {
    description = "type of instance"
    type = string
    default = "t2.micro"
}

variable "key_name" {
    description = "key for instance"
    type = string
    default = "bhola-ubuntu"
}

variable "name" {
    description = "name of instance"
    type = string
    default = "bhola-terraform"
}

variable "security_groups" {
    description = "security group for instance"
    type = string
    default = "default"
}
