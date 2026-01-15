variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "test-key"
}

variable "public_key" {
  description = "Public key for the key pair"
  type        = string
  default     = file("~/.ssh/id_rsa.pub")
}
