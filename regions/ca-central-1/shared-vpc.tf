locals {
  shared-vpc-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}

resource "aws_vpc" "shared_vpc" {
  cidr_block = "172.22.0.0/16"
  tags = merge(local.shared-vpc-tags, {
    Name = "shared-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.shared_vpc.id
  tags = merge(local.shared-vpc-tags, {
    Name = "shared-vpc-igw"
  })
}
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.shared_vpc.id
  cidr_block = "172.22.10.0/24"
  tags = merge(local.shared-vpc-tags, {
    Name = "shared-vpc-public-subnet"
  })

}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.shared_vpc.id
  cidr_block = "172.22.20.0/24"
  tags = merge(local.shared-vpc-tags, {
    Name = "shared-vpc-private-subnet"
  })
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = merge(local.shared-vpc-tags, {
    Name = "shared-vpc-eip"
  })
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = merge(local.shared-vpc-tags, {
    Name = "shared-vpc-nat"
  })
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.shared_vpc.id
  tags = merge(local.shared-vpc-tags, {
    Name = "shared-vpc-private-rt"
  })
}

# Default route to NAT Gateway — now as a separate resource
resource "aws_route" "default-to-nat" {
  route_table_id         = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

variable "spoke_cidrs" {

  description = "List of destination CIDRs to route through TGW"
  type        = list(string)
  default = [
    "172.16.20.0/24",
    "172.18.20.0/24",
    "172.20.20.0/24",
    "172.31.0.0/16"
  ]
}

resource "aws_route" "shared-vpc-to-all" {
  route_table_id         = aws_route_table.private_route.id
  for_each               = toset(var.spoke_cidrs)
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}