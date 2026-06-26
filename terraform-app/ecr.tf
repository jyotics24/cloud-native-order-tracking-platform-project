# ecr.tf
# Creates an ECR (Elastic Container Registry) repository to store
# the order-tracking-app Docker image. Jenkins pushes images here
# after the Docker Build + Trivy Scan stages succeed.

resource "aws_ecr_repository" "order_tracking_app" {
  name = "order-tracking-app"
  force_delete = true

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "order-tracking-app-ecr"
    Project = "Cloud-Native-Order-Tracking"
  }
}
