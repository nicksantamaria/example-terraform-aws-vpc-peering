resource "aws_vpc" "secondary" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "secondary" {
  vpc_id = "${aws_vpc.secondary.id}"
}

resource "aws_route" "secondary-internet_access" {
  route_table_id         = "${aws_vpc.secondary.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.secondary.id}"
}

resource "aws_subnet" "secondary-az1" {
  vpc_id                  = "${aws_vpc.secondary.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"
}

resource "aws_subnet" "secondary-az2" {
  vpc_id                  = "${aws_vpc.secondary.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2b"
}

resource "aws_security_group" "secondary-default" {
  name_prefix = "default-"
  description = "Default security group for all instances in VPC ${aws_vpc.secondary.id}"
  vpc_id      = "${aws_vpc.secondary.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
