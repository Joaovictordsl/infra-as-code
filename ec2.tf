resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "my-key-ssh"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "${path.module}/my-terraform-key.pem"
}

resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Allow SSH, HTTP/HTTPS connections"

  tags = {
    Name        = "website"
    Provisioned = "Terraform"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["191.185.181.57/32"]
  }

  egress {
    from_port   = 0
    to_port     = 65350
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "ec2-server" {
  ami                    = "ami-07ff62358b87c7116"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name #aws_iam_instance_profile.ec2_profile.name
}
