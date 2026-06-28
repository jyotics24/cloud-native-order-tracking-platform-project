# vpc-eks.tf
# Dedicated VPC for the EKS cluster. EKS requires subnets in at
# least 2 Availability Zones, and recommends both public subnets
# (for load balancers) and private subnets (for worker nodes).
# This is separate from the Jenkins EC2's VPC.

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# ---------------------------------------------------
# Public subnets (2 AZs) - for load balancers
# ---------------------------------------------------
resource "aws_subnet" "eks_public_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block               = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "eks-public-1"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/order-tracking-eks"   = "shared"
  }
}

resource "aws_subnet" "eks_public_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block               = "10.1.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "eks-public-2"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/order-tracking-eks"   = "shared"
  }
}

# ---------------------------------------------------
# Private subnets (2 AZs) - for EKS worker nodes
# ---------------------------------------------------
resource "aws_subnet" "eks_private_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name                                          = "eks-private-1"
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/order-tracking-eks"     = "shared"
  }
}

resource "aws_subnet" "eks_private_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                                          = "eks-private-2"
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/order-tracking-eks"     = "shared"
  }
}

# ---------------------------------------------------
# NAT Gateway - lets private subnet nodes reach the
# internet (e.g. to pull container images) without
# being directly publicly reachable themselves.
# ---------------------------------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip"
  }
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.eks_public_1.id

  tags = {
    Name = "eks-nat"
  }

  depends_on = [aws_internet_gateway.eks_igw]
}

# ---------------------------------------------------
# Route tables
# ---------------------------------------------------
resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-public-rt"
  }
}

resource "aws_route_table" "eks_private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat.id
  }

  tags = {
    Name = "eks-private-rt"
  }
}

resource "aws_route_table_association" "eks_public_1_assoc" {
  subnet_id      = aws_subnet.eks_public_1.id
  route_table_id = aws_route_table.eks_public_rt.id
}

resource "aws_route_table_association" "eks_public_2_assoc" {
  subnet_id      = aws_subnet.eks_public_2.id
  route_table_id = aws_route_table.eks_public_rt.id
}

resource "aws_route_table_association" "eks_private_1_assoc" {
  subnet_id      = aws_subnet.eks_private_1.id
  route_table_id = aws_route_table.eks_private_rt.id
}

resource "aws_route_table_association" "eks_private_2_assoc" {
  subnet_id      = aws_subnet.eks_private_2.id
  route_table_id = aws_route_table.eks_private_rt.id
}

# =========================================================================
# NEW: Security Group Rule to Open NodePorts for External Load Balancers
# =========================================================================
resource "aws_security_group_rule" "allow_lb_to_nodes" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow inbound traffic from Load Balancers to EKS NodePorts"
  
  # Links dynamically to the auto-generated group created by your EKS resource
  security_group_id = aws_eks_cluster.order_tracking_eks.vpc_config[0].cluster_security_group_id
}