# ==================================================
# Jenkins Public IP
# ==================================================

output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

# ==================================================
# Jenkins Public DNS
# ==================================================

output "jenkins_public_dns" {
  value = aws_instance.jenkins_server.public_dns
}