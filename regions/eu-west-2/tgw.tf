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
    Name = "VPC-B Attachment"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-c-attachment" {
  subnet_ids         = [module.vpc-c.private_subnet]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc-c.vpc_id
  tags = merge(local.tgw-tags, {
    Name = "VPC-C Attachment"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shared-vpc-attachment" {
  subnet_ids         = [aws_subnet.private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.shared_vpc.id
  tags = merge(local.tgw-tags, {
    Name = "Shared VPC Attachment"
  })
}


resource "aws_ec2_transit_gateway_route_table" "rt-full-mesh" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(local.tgw-tags, {
    Name = "Full Mesh Route Table"
  })
}

resource "aws_ec2_transit_gateway_route_table" "rt-shared" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(local.tgw-tags, {
    Name = "Shared Services Route Table"
  })
}

resource "aws_ec2_transit_gateway_route_table" "rt-isolated" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(local.tgw-tags, {
    Name = "Isolated Route Table"
  })
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc-a-into-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-a-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}
resource "aws_ec2_transit_gateway_route_table_association" "vpc-b-into-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-b-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}
resource "aws_ec2_transit_gateway_route_table_association" "shared-vpc-into-shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id
}
resource "aws_ec2_transit_gateway_route_table_association" "isolated_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-c-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-isolated.id
}

resource "aws_ec2_transit_gateway_route_table_association" "peering-association-to-full-mesh-rt" {
  transit_gateway_attachment_id  = "tgw-attach-01de207ef227a3377"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id

}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-a-to-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-a-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-b-to-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-b-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "shared-vpc-to-full-mesh" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "shared-vpc-to-isolated" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared-vpc-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-isolated.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-c-to-isolated" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-c-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-isolated.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-a-to-shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-a-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-b-to-shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc-b-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id
}

resource "aws_ec2_transit_gateway_route" "vpc-c-blackhole-on-full-mesh-rt" {
  destination_cidr_block         = "10.30.0.0/16"
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route" "vpc-c-to-shared-vpc-on-full-mesh-rt" {
  destination_cidr_block         = "172.22.0.0/16"
  transit_gateway_attachment_id  = "tgw-attach-01de207ef227a3377"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-full-mesh.id
}

resource "aws_ec2_transit_gateway_route" "vpc-c-to-shared-vpc-on-shared-rt" {
  destination_cidr_block         = "172.22.0.0/16"
  transit_gateway_attachment_id  = "tgw-attach-01de207ef227a3377"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt-shared.id
}