/**
 * VPC.
 *
 * Virtual network which will be referred to as "secondary" in this example.
 */
resource "aws_vpc" "secondary" {
  cidr_block = "10.0.0.0/16"
}

/**
 * Internet gateway (IGW).
 *
 * Gateway which allows traffic to/from the "secondary" VPC to the public
 * internet.
 */
resource "aws_internet_gateway" "secondary" {
  vpc_id = aws_vpc.secondary.id
}

/**
 * Route rule.
 *
 * Directs all traffic (which doesn't match another route) to the IGW.
 */
resource "aws_route" "secondary-internet_access" {
  route_table_id         = aws_vpc.secondary.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.secondary.id
}

/**
 * Subnet.
 *
 * /24 subnet for availability zone "a".
 */
resource "aws_subnet" "secondary-az1" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
}

/**
 * Subnet.
 *
 * /24 subnet for availability zone "b".
 */
resource "aws_subnet" "secondary-az2" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"
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
resource "aws_security_group" "secondary-default" {
  name_prefix = "default-"
  description = "Default security group for all instances in VPC ${aws_vpc.secondary.id}"
  vpc_id      = aws_vpc.secondary.id

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
