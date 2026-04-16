locals {
  tags = {
    project   = "networking-project"
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet
  availability_zone = var.availability_zone
  tags = merge(local.tags, {
    Name = "${var.vpc_name}-private-subnet"
  })
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "${var.vpc_name}-private-rt"
  })
}


resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}