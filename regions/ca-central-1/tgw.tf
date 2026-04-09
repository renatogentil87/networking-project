locals {
  tgw-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
    Name      = "Networking Project TGW"
  }
}

resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway Interconnection Canada <> London"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  tags                            = merge(local.tgw-tags, )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-a-attachment" {
  subnet_ids         = [module.vpc-a.private_subnet]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc-a.vpc_id
  tags = merge(local.tgw-tags, {
  Name = "VPC-A Attachment" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-b-attachment" {
  subnet_ids         = [module.vpc-b.private_subnet]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc-b.vpc_id
  tags = merge(local.tgw-tags, {
  Name = "VPC-B Attachment" })
}
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-c-attachment" {
  subnet_ids         = [module.vpc-c.private_subnet]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc-c.vpc_id
  tags = merge(local.tgw-tags, {
  Name = "VPC-C Attachment" })
}
resource "aws_ec2_transit_gateway_vpc_attachment" "shared-vpc-attachment" {
  subnet_ids         = [aws_subnet.private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.shared_vpc.id
  tags = merge(local.tgw-tags, {
  Name = "Shared-VPC Attachment" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "firewall_vpc_attachment" {
  subnet_ids = [
    aws_subnet.firewall-tgw-subnet.id
  ]
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  vpc_id                 = aws_vpc.firewall-vpc.id
  appliance_mode_support = "enable"

  tags = merge(local.tgw-tags, {
    Name = "Firewall VPC Attachment"
  })
}


#---Shared Route Table (VPC A, B and Shared VPC)
resource "aws_ec2_transit_gateway_route_table" "rt-shared" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(local.tgw-tags, {
  Name = "Shared Route Table" })
}
# Isolated Route Table
resource "aws_ec2_transit_gateway_route_table" "rt-isolated" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(local.tgw-tags, {
  Name = "VPC-C Isolated Route Table" })
}

# Full Mesh Route Table (VPC A and B) - VPC-C is isolated
resource "aws_ec2_transit_gateway_route_table" "rt-full-mesh" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(local.tgw-tags, {
    Name = "Full Mesh Route Table (VPC-A, VPC-B)"
  })
}

resource "aws_ec2_transit_gateway_route_table" "firewall-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(local.tgw-tags, {
    Name = "Firewall Route Table"
  })
}

resource "aws_ec2_transit_gateway_route_table_association" "firewall-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc-c-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-c-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-isolated.id
}


resource "aws_ec2_transit_gateway_route_table_association" "vpc-a-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-a-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc-b-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-b-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route_table_association" "shared-vpc-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id
}

resource "aws_ec2_transit_gateway_route_table_association" "peering-association-full-mesh-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering-to-london-region.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-a-into-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-a-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-b-into-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-b-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "shared-vpc-into-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}



resource "aws_ec2_transit_gateway_route_table_propagation" "shared-into-isolated" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-isolated.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-a-into-shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-a-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-b-into-shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-b-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id
}


resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-b-into-firewall-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-b-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall-rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-a-into-firewall-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-a-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall-rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared-vpc-into-firewall-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall-rt.id
}

resource "aws_ec2_transit_gateway_route" "vpc-a-canada-to-vpc-b-london" {
  destination_cidr_block         = "10.20.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering-to-london-region.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route" "vpc-c-blackhole" {
  destination_cidr_block         = "172.20.0.0/16"
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route" "internet-via-firewall" {
  destination_cidr_block         = "0.0.0.0/0"
  blackhole                      = false
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}


####### Peering Configuration 

# Requestor (uses default provider - ca-central-1)
resource "aws_ec2_transit_gateway_peering_attachment" "peering-to-london-region" {
  peer_account_id         = "223318879912"
  peer_region             = "eu-west-2"
  peer_transit_gateway_id = "tgw-09ab9333bcf15e162"
  transit_gateway_id      = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

# Accepter (uses aws.peer provider - eu-west-2)
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "accept-from-canada" {
  provider                      = aws.peer
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.peering-to-london-region.id

  tags = {
    Name = "TGW Peering Accepter - Canada"
  }
}

## VPN Configuration

resource "aws_ec2_transit_gateway_route_table_association" "vpn" {
  transit_gateway_attachment_id  = aws_vpn_connection.vpn-to-canada.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_propagation" {
  transit_gateway_attachment_id  = aws_vpn_connection.vpn-to-canada.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_propagation_to_shared-rt" {
  transit_gateway_attachment_id  = aws_vpn_connection.vpn-to-canada.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id

}


resource "aws_ec2_transit_gateway_route" "firewall-rt-default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.firewall_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall-rt.id
}