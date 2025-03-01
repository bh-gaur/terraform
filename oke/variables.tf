variable "compartment_ocid" {
  description = "The OCID of the compartment where OKE resources will be created"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain where the worker nodes will be placed"
  type        = string
}

variable "oke_image_id" {
  description = "The OCID of the image to use for OKE worker nodes"
  type        = string
}
