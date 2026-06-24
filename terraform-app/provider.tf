# provider.tf
# AWS provider for application infrastructure (ECR, later EKS).
# This is a SEPARATE Terraform project from terraform/ (which
# manages the permanent Jenkins EC2). Keeping them apart means
# Jenkins' pipeline can safely run terraform apply here without
# any risk of touching the server it's running on.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
