data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]

  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ec2_tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.vpc_name}-keypair"
  public_key = tls_private_key.ec2_key.public_key_openssh
  lifecycle {
    ignore_changes = all
  }
}
resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${var.key_output_path}/${var.vpc_name}-keypair.pem"
  file_permission = "0400"
  lifecycle {
    ignore_changes = all
  }
}

output "key_pair_name" {
  value = aws_key_pair.ec2_key_pair.key_name
}

output "private_key_path" {
  value = local_file.private_key.filename
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  tags = merge(local.ec2_tags, {
    Name = "EC2-${var.vpc_name}"
  })
}

resource "aws_security_group" "private_sg" {
  name        = "allow inbound traffic"
  description = "Allow  inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
  tags = merge(local.ec2_tags, {
    Name = "${var.vpc_name}-private-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
  for_each          = toset(var.allowed_cidr)
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = each.value
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_ssh" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = "172.22.0.0/16"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22

}