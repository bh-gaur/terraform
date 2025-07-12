variable "cidr_block" {
  description = "cidr_block for my_vpc"
  type = "string"
  default = ""
}

variable "aws_vpc_name" {
  description = ""
  type = string
  default = ""
}

variable "public_subnet_cidr_block" {
  description = ""
  type = string
  default = ""
}

variable "public_subnet_name" {
  description = ""
  type = string
  default = ""
}

variable "availability_zone" {
  description = ""
  type = string
  default = ""
}

variable "private_subnet_cidr_block" {
  description = ""
  type = string
  default = ""
}

variable "private_subnet_name" {
  description = ""
  type = string
  default = ""
}

variable "igw_name" {
  description = ""
  type = string
  default = ""
}

