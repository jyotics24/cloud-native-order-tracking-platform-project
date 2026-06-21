# ==================================================
# Get Latest Amazon Linux 2023 AMI
# ==================================================
# Automatically fetches the latest Amazon Linux 2023
# AMI from AWS.
#
# This avoids hardcoding AMI IDs, which change
# frequently across regions and over time.
# ==================================================

data "aws_ami" "amazon_linux" {

  # Get the most recent matching AMI
  most_recent = true

  # Official AWS account
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ==================================================
# Jenkins EC2 Instance
# ==================================================
# Creates an EC2 instance that will later be
# configured by Ansible.
#
# Ansible will install:
# - Docker
# - Git
# - Java 21
# - Jenkins
# ==================================================

resource "aws_instance" "jenkins_server" {

  # Latest Amazon Linux 2023 AMI
  ami = data.aws_ami.amazon_linux.id

  # Recommended size for Jenkins + Docker
  instance_type = "t3.micro"

  # Existing AWS Key Pair
  # Required for SSH access
  key_name = "jenkins-key"

  # Public subnet created in subnet.tf
  subnet_id = aws_subnet.public_subnet.id

  # Security Group created in sg.tf
  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]

  # Assign Public IP automatically
  associate_public_ip_address = true

  # Root Volume Configuration
  root_block_device {

    # Storage Size (GB)
    volume_size = 30

    # General Purpose SSD
    volume_type = "gp3"

    # Delete volume when EC2 is terminated
    delete_on_termination = true
  }

  # Tags
  tags = {
    Name        = "jenkins-server"
    Environment = "Dev"
    Project     = "Cloud-Native-Order-Tracking"
  }
}