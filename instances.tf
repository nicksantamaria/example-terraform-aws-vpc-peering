resource "aws_instance" "primary-az1" {
  instance_type          = var.instance_class
  ami                    = var.ami_id
  key_name               = var.key_name
  subnet_id              = aws_subnet.primary-az1.id
  vpc_security_group_ids = [aws_security_group.primary-default.id]

  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
    ]
  }
}

resource "aws_instance" "primary-az2" {
  instance_type          = var.instance_class
  ami                    = var.ami_id
  key_name               = var.key_name
  subnet_id              = aws_subnet.primary-az2.id
  vpc_security_group_ids = [aws_security_group.primary-default.id]

  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
    ]
  }
}

resource "aws_instance" "secondary-az1" {
  instance_type          = var.instance_class
  ami                    = var.ami_id
  key_name               = var.key_name
  subnet_id              = aws_subnet.secondary-az1.id
  vpc_security_group_ids = [aws_security_group.secondary-default.id]

  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
    ]
  }
}

resource "aws_instance" "secondary-az2" {
  instance_type          = var.instance_class
  ami                    = var.ami_id
  key_name               = var.key_name
  subnet_id              = aws_subnet.secondary-az2.id
  vpc_security_group_ids = [aws_security_group.secondary-default.id]

  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
    ]
  }
}

