# ==================================================
# Get Latest Ubuntu 24.04 LTS AMI via SSM
# ==================================================
# Uses AWS's official SSM Parameter Store path, which
# Canonical and AWS keep updated automatically. This is
# more reliable than wildcard name matching, which can
# break if Ubuntu changes its AMI naming convention.
#
# Ubuntu does not restrict /tmp to a small RAM-backed
# filesystem like Amazon Linux 2023 does, avoiding the
# Jenkins "Free Temp Space" false-positive entirely.
# ==================================================
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
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

  # Latest Ubuntu 24.04 LTS AMI
  ami = data.aws_ssm_parameter.ubuntu.value

  # Recommended size for Jenkins + Docker
  instance_type = "c7i-flex.large"

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