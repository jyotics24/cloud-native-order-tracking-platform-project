# ==================================================
# Public Subnet
# ==================================================
# This subnet will host the Jenkins EC2 instance.
# Public IPs are enabled so we can access Jenkins
# from the internet.
# ==================================================

resource "aws_subnet" "public_subnet" {

  # VPC where subnet will be created
  vpc_id = aws_vpc.main.id

  # Subnet CIDR range
  cidr_block = "10.0.1.0/24"

  # AWS Availability Zone
  availability_zone = "us-east-1a"

  # Automatically assign public IPs
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-public-subnet"
  }
}

# ==================================================
# Public Route Table
# ==================================================
# Routes internet traffic through the Internet Gateway.
# Required so Jenkins can access:
# - GitHub
# - Jenkins Plugins
# - Docker Hub
# ==================================================

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {

    # Internet Route
    cidr_block = "0.0.0.0/0"

    # Internet Gateway from vpc.tf
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "jenkins-public-route-table"
  }
}

# ==================================================
# Route Table Association
# ==================================================
# Connects subnet to the public route table.
# ==================================================

resource "aws_route_table_association" "public_assoc" {

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}