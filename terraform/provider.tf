# ==================================================
# Terraform Version & Provider Requirements
# ==================================================

terraform {

  # Minimum Terraform version required
  required_version = ">= 1.5.0"

  # AWS Provider Configuration
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ==================================================
# AWS Provider
# ==================================================

provider "aws" {

  # AWS Region where resources will be created
  region = "us-east-1"

}