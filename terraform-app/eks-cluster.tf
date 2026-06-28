# eks-cluster.tf
# Creates the EKS cluster and a managed node group to run
# the order-tracking-app. Uses the VPC/subnets from vpc-eks.tf
# and the IAM roles from iam-eks.tf.

resource "aws_eks_cluster" "order_tracking_eks" {
  name     = "order-tracking-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_public_1.id,
      aws_subnet.eks_public_2.id,
      aws_subnet.eks_private_1.id,
      aws_subnet.eks_private_2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "order_tracking_nodes" {
  cluster_name    = aws_eks_cluster.order_tracking_eks.name
  node_group_name = "order-tracking-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.eks_private_1.id,
    aws_subnet.eks_private_2.id
  ]

  # Small, cost-conscious node group: 1-2 t3.small nodes
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly_policy
  ]
}

# =========================================================================
# FIXED: Safe rule attachment that targets the cluster security group
# directly to avoid remote_access SSH key requirements.
# =========================================================================
resource "aws_security_group_rule" "allow_lb_to_nodes_fixed" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow inbound Classic Load Balancer traffic to EKS NodePorts"
  security_group_id = aws_eks_cluster.order_tracking_eks.vpc_config[0].cluster_security_group_id
}