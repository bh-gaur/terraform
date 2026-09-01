# Terraform AWS Guide & Provider Comparison

Terraform is an open-source Infrastructure as Code (IaC) tool by HashiCorp that lets you provision, manage, and version cloud infrastructure safely and predictably across multiple cloud providers.

---

## ☁️ AWS Terraform Providers: `aws` vs. `awscc`

When provisioning AWS infrastructure with Terraform, HashiCorp and AWS offer two distinct providers: the standard **`aws`** provider and the newer **`awscc`** (AWS Cloud Control) provider.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
  }
}

# 1. Standard AWS Provider
provider "aws" {
  region = var.aws_region
}

# 2. AWS Cloud Control (AWSCC) Provider
provider "awscc" {
  region = var.aws_region
}
```

---

## 🔍 Detailed Provider Comparison

### 1. `aws` Provider (Standard)

* **What it is:** The traditional, battle-tested, primary Terraform provider for AWS maintained jointly by HashiCorp and the community.
* **How it works:** Makes direct API calls to individual AWS service endpoints (e.g., EC2, S3, IAM, VPC, RDS).
* **Strengths:**
  - **Mature & Comprehensive:** Extremely well-documented with extensive community examples and modules.
  - **Idiomatic Syntax:** Uses native, human-friendly Terraform HCL patterns and conventions.
  - **Broad Coverage:** Supports virtually all legacy, current, and custom AWS configurations.
* **Limitations:**
  - When AWS announces a new service or feature at re:Invent/launch, it requires manual implementation by HashiCorp/community contributors before it becomes available in the provider.

---

### 2. `awscc` Provider (AWS Cloud Control API)

* **What it is:** A modern provider built on top of the **AWS Cloud Control API** and the CloudFormation Schema Registry.
* **How it works:** Interacts directly with AWS Cloud Control API, auto-generating Terraform schema automatically from AWS CloudFormation resource specifications.
* **Strengths:**
  - **Day-1 Support for New Features:** As soon as AWS releases a new service or resource in CloudFormation, it is instantly supported without waiting for manual provider updates.
  - **Consistency:** Standardized CRUDL (Create, Read, Update, Delete, List) operations generated directly by AWS schemas.
* **Limitations:**
  - Does not support older/legacy AWS services that lack Cloud Control API integration.
  - Resource syntax closely mirrors CloudFormation schema, which can sometimes feel less idiomatic compared to the standard `aws` provider.

---

## 📊 Summary Comparison Table

| Feature / Criteria | Standard `aws` Provider | AWS Cloud Control `awscc` Provider |
|---|---|---|
| **Underlying API** | Direct Service APIs (EC2, S3, etc.) | AWS Cloud Control API (CloudFormation Registry) |
| **New Feature Availability** | Requires community/HashiCorp implementation | **Day-1 immediate availability** upon AWS launch |
| **Maturity & Docs** | High maturity, extensive guides | Modern, schema-generated documentation |
| **Community Modules** | Vast ecosystem of verified modules | Growing ecosystem |
| **Best For** | Core infrastructure (VPC, EC2, IAM, EKS, RDS) | Cutting-edge services & brand new AWS features |

---

## 💡 Why & When to Use Both Together in DevOps?

In enterprise DevOps engineering, it is standard practice to declare **both providers in the same Terraform project**:

1. **Use `aws` (Standard)** for the vast majority (90–95%) of your core infrastructure (VPC, IAM, EKS, EC2, S3, Security Groups) to leverage rich community modules and mature lifecycle handling.
2. **Use `awscc` (Cloud Control)** selectively for brand-new AWS services or feature flags that have just been announced and are not yet implemented in the standard `aws` provider.

---

## 🛠️ Installation Guide

### macOS (Homebrew)
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Linux (Debian / Ubuntu)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Verify Installation
```bash
terraform version
```