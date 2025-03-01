provider "oci" {
  tenancy_ocid         = "<tenancy_ocid>"
  user_ocid            = "<user_ocid>"
  fingerprint          = "<fingerprint>"
  private_key_path     = "<path_to_private_key>"
  region               = "<region>"
  compartment_ocid     = "<compartment_ocid>"
}

# Create a VCN
resource "oci_core_vcn" "oke_vcn" {
  cidr_block     = "10.0.0.0/16"
  display_name   = "oke-vcn"
  compartment_id = var.compartment_ocid
}

# Create a public subnet
resource "oci_core_subnet" "oke_public_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  cidr_block     = "10.0.1.0/24"
  display_name   = "oke-public-subnet"
  security_list_ids = [oci_core_default_security_list.oke_security_list.id]
}

# Create an Internet Gateway
resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-internet-gateway"
  enabled        = true
}

# Create a route table for public subnet
resource "oci_core_default_route_table" "oke_route_table" {
  vcn_id = oci_core_vcn.oke_vcn.id

  route_rules {
    cidr_block = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.oke_igw.id
  }
}

# Create Security List (allowing necessary ingress/egress traffic)
resource "oci_core_default_security_list" "oke_security_list" {
  vcn_id = oci_core_vcn.oke_vcn.id

  # Allow SSH, Kubernetes ports, and more
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}

# Create Kubernetes OKE cluster
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id = var.compartment_ocid
  name           = "oke-cluster"
  vcn_id         = oci_core_vcn.oke_vcn.id

  kubernetes_version = "v1.25.4" # Use the latest supported version

  options {
    service_lb_subnet_ids = [oci_core_subnet.oke_public_subnet.id]
  }
}

# Create worker nodes (Node Pool)
resource "oci_containerengine_node_pool" "oke_node_pool" {
  compartment_id = var.compartment_ocid
  cluster_id     = oci_containerengine_cluster.oke_cluster.id
  name           = "oke-node-pool"

  node_shape = "VM.Standard2.1" # Define shape for worker nodes

  node_config_details {
    size = 3 # Number of nodes
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = oci_core_subnet.oke_public_subnet.id
    }
  }

  kubernetes_version = oci_containerengine_cluster.oke_cluster.kubernetes_version

  node_source_details {
    image_id = var.oke_image_id
    source_type = "image"
  }
}
