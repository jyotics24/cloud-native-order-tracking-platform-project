# outputs.tf
# Outputs the ECR repository URL so Jenkins can reference it
# when tagging and pushing Docker images.

output "ecr_repository_url" {
  value = aws_ecr_repository.order_tracking_app.repository_url
}

output "eks_cluster_name" {
  value = aws_eks_cluster.order_tracking_eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.order_tracking_eks.endpoint
}
