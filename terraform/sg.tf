# ==================================================
# Security Group for Jenkins EC2
# ==================================================
# Controls inbound and outbound traffic.
# Allows:
# - SSH (22)
# - Jenkins UI (8080)
# - All outbound traffic
# ==================================================

resource "aws_security_group" "jenkins_sg" {

  name        = "jenkins-security-group"
  description = "Security Group for Jenkins Server"
  vpc_id      = aws_vpc.main.id

  # ==========================================
  # SSH Access
  # ==========================================

  ingress {
    description = "SSH Access"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # ==========================================
  # Jenkins Web UI
  # ==========================================

  ingress {
    description = "Jenkins Web UI"

    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # ==========================================
  # Outbound Internet Access
  # ==========================================

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-security-group"
  }
}