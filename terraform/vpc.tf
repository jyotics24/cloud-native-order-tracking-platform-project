# ==================================================
# VPC
# ==================================================
# Creates a dedicated network for the project.
# All AWS resources will be placed inside this VPC.
# ==================================================

resource "aws_vpc" "main" {

  # CIDR block for the VPC
  cidr_block = "10.0.0.0/16"

  # Enable DNS hostnames
  enable_dns_hostnames = true

  # Enable DNS support
  enable_dns_support = true

  tags = {
    Name = "jenkins-vpc"
  }
}

# ==================================================
# Internet Gateway
# ==================================================
# Allows communication between the VPC and Internet.
# Required for Jenkins EC2 public access.
# ==================================================

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "jenkins-igw"
  }
}