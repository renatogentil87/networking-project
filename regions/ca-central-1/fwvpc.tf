locals {
  firewall-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}

# VPC
resource "aws_vpc" "firewall-vpc" {
  cidr_block = "100.64.0.0/16"
  tags = merge(local.firewall-tags, {
    Name = "firewall-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.firewall-vpc.id
  tags = merge(local.firewall-tags, {
    Name = "firewall-internet-gateway"
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "elastic-ip" {
  domain = "vpc"
  tags = merge(local.firewall-tags, {
    Name = "firewall-vpc-eip"
  })
}

# ===== SUBNET 1: TGW Attachment Subnet =====
resource "aws_subnet" "firewall-tgw-subnet" {
  vpc_id            = aws_vpc.firewall-vpc.id
  availability_zone = "ca-central-1a"
  cidr_block        = "100.64.30.0/24"
  tags = merge(local.firewall-tags, {
    Name = "firewall-tgw-subnet"
  })
}

resource "aws_route_table" "firewall-tgw-route-table" {
  vpc_id = aws_vpc.firewall-vpc.id
  tags = merge(local.firewall-tags, {
    Name = "firewall-tgw-route-table"
  })
}

resource "aws_route" "tgw-to-firewall-endpoint" {
  route_table_id         = aws_route_table.firewall-tgw-route-table.id
  vpc_endpoint_id        = "vpce-0beb16e3ff4353b12"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "tgw_subnet_assoc" {
  subnet_id      = aws_subnet.firewall-tgw-subnet.id
  route_table_id = aws_route_table.firewall-tgw-route-table.id
}

# ===== SUBNET 2: Firewall Subnet (Private) =====
resource "aws_subnet" "firewall-private-subnet" {
  vpc_id            = aws_vpc.firewall-vpc.id
  availability_zone = "ca-central-1a"
  cidr_block        = "100.64.10.0/24"
  tags = merge(local.firewall-tags, {
    Name = "firewall-private-subnet"
  })
}

resource "aws_route_table" "firewall-private-route-table" {
  vpc_id = aws_vpc.firewall-vpc.id
  tags = merge(local.firewall-tags, {
    Name = "firewall-private-route-table"
  })
}


resource "aws_route" "return-traffic-to-vpc-a" {
  route_table_id         = aws_route_table.firewall-public-route-table.id
  vpc_endpoint_id        = "vpce-0beb16e3ff4353b12"
  destination_cidr_block = "172.16.0.0/16"
}

resource "aws_route" "return-traffic-to-vpc-b" {
  route_table_id         = aws_route_table.firewall-public-route-table.id
  vpc_endpoint_id        = "vpce-0beb16e3ff4353b12"
  destination_cidr_block = "172.18.0.0/16"
}


resource "aws_route" "return-traffic-to-shared-vpc" {
  route_table_id         = aws_route_table.firewall-public-route-table.id
  vpc_endpoint_id        = "vpce-0beb16e3ff4353b12"
  destination_cidr_block = "172.22.0.0/16"
}

resource "aws_route" "firewall-to-natgw" {
  route_table_id         = aws_route_table.firewall-private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnet_assocotiation" {
  subnet_id      = aws_subnet.firewall-private-subnet.id
  route_table_id = aws_route_table.firewall-private-route-table.id
}

resource "aws_route" "firewall-to-vpc-b" {
  route_table_id         = aws_route_table.firewall-private-route-table.id
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  destination_cidr_block = "172.18.0.0/16"
}
resource "aws_route" "firewall-to-vpc-a" {
  route_table_id         = aws_route_table.firewall-private-route-table.id
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  destination_cidr_block = "172.16.0.0/16"
}
resource "aws_route" "firewall-to-shared-vpc" {
  route_table_id         = aws_route_table.firewall-private-route-table.id
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  destination_cidr_block = "172.22.0.0/16"
}

# ===== SUBNET 3: Public Subnet (NAT Gateway) =====
resource "aws_subnet" "firewall-public-subnet" {
  vpc_id            = aws_vpc.firewall-vpc.id
  availability_zone = "ca-central-1a"
  cidr_block        = "100.64.20.0/24"
  tags = merge(local.firewall-tags, {
    Name = "firewall-public-subnet"
  })
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.firewall-public-subnet.id
  tags = merge(local.firewall-tags, {
    Name = "firewall-vpc-nat"
  })
}

resource "aws_route_table" "firewall-public-route-table" {
  vpc_id = aws_vpc.firewall-vpc.id
  tags = merge(local.firewall-tags, {
    Name = "firewall-public-route-table"
  })
}

resource "aws_route" "public-to-internet" {
  route_table_id         = aws_route_table.firewall-public-route-table.id
  gateway_id             = aws_internet_gateway.internet-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.firewall-public-subnet.id
  route_table_id = aws_route_table.firewall-public-route-table.id
}
