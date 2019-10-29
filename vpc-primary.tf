/**
 * VPC.
 *
 * Virtual network which will be referred to as "secondary" in this example.
 */
resource "aws_vpc" "primary" {
  cidr_block = "172.30.0.0/16"
}

/**
 * Internet gateway (IGW).
 *
 * Gateway which allows traffic to/from the "primary" VPC to the public
 * internet.
 */
resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primary.id
}

/**
 * Route rule.
 *
 * Directs all traffic (which doesn't match another route) to the IGW.
 */
resource "aws_route" "primary-internet_access" {
  route_table_id         = aws_vpc.primary.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.primary.id
}

/**
 * Subnet.
 *
 * /24 subnet for availability zone "a".
 */
resource "aws_subnet" "primary-az1" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.30.131.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"
}

/**
 * Subnet.
 *
 * /24 subnet for availability zone "b".
 */
resource "aws_subnet" "primary-az2" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.30.132.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2b"
}

/**
 * Security group.
 *
 * Basic security group with the following rules:
 *  - Inbound traffic on port 80 restricted to private IPs.
 *  - Inbound traffic on port 22 unrestricted (enables us to setup instances
 *    and  run tests).
 *  - Outbound traffic unrestricted.
 */
resource "aws_security_group" "primary-default" {
  name_prefix = "default-"
  description = "Default security group for all instances in VPC ${aws_vpc.primary.id}"
  vpc_id      = aws_vpc.primary.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.primary.cidr_block,
      aws_vpc.secondary.cidr_block,
    ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

