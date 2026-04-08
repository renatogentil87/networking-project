locals {
  common_tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}

module "vpc-a" {
  source            = "../../modules/networking"
  vpc_cidr          = "172.16.0.0/16"
  vpc_name          = "vpc-a"
  private_subnet    = "172.16.20.0/24"
  availability_zone = "ca-central-1a"
  tags = merge(local.common_tags, {
    Name = "vpc-a"
  })
}

variable "shared-vpc-and-vpc-b-cidr" {
  description = "CIDR of VPC B and Shared VPC"
  type        = list(string)
  default     = ["172.18.20.0/24", "172.22.20.0/24"]
}
resource "aws_route" "vpc-a-to-shared-and-to-b" {
  for_each               = toset(var.shared-vpc-and-vpc-b-cidr)
  route_table_id         = module.vpc-a.private_route_id
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "vpc-a-to-internet-via-shared-vpc" {
  route_table_id         = module.vpc-a.private_route_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}
resource "aws_route" "vpc-a-canada-to-vpc-a-london" {
  route_table_id         = module.vpc-a.private_route_id
  destination_cidr_block = "10.10.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

}

variable "vpn_cidrs" {

  description = "List of destination CIDRs to route through VPN"
  type        = list(string)
  default = [
    "192.168.10.0/24",
    "192.168.20.0/24"
  ]
}
resource "aws_route" "vpc-a-to-vpn" {
  for_each               = toset(var.vpn_cidrs)
  route_table_id         = module.vpc-a.private_route_id
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

}

module "vpc-b" {
  source            = "../../modules/networking"
  vpc_cidr          = "172.18.0.0/16"
  vpc_name          = "vpc-b"
  private_subnet    = "172.18.20.0/24"
  availability_zone = "ca-central-1a"

  tags = merge(local.common_tags, {
    Name = "vpc-b"
  })
}
resource "aws_route" "vpc-b-to-a" {
  route_table_id         = module.vpc-b.private_route_id
  destination_cidr_block = "172.16.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

}

resource "aws_route" "vpc-b-to-shared-vpc" {
  route_table_id         = module.vpc-b.private_route_id
  destination_cidr_block = "172.22.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

}

resource "aws_route" "vpc-b-canada-to-london-vpc-b" {
  destination_cidr_block = "10.10.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  route_table_id         = module.vpc-b.private_route_id
}

resource "aws_route" "vpc-a-canada-to-london-vpc-b" {
  destination_cidr_block = "10.20.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  route_table_id         = module.vpc-a.private_route_id
}

resource "aws_route" "vpc-b-to-internet-via-tgw" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  route_table_id         = module.vpc-b.private_route_id
}

module "vpc-c" {
  source            = "../../modules/networking"
  vpc_cidr          = "172.20.0.0/16"
  vpc_name          = "vpc-c"
  private_subnet    = "172.20.20.0/24"
  availability_zone = "ca-central-1a"

  tags = merge(local.common_tags, {
    Name = "vpc-c"
  })
}

resource "aws_route" "vpc-c-to-shared-vpc" {
  route_table_id         = module.vpc-c.private_route_id
  destination_cidr_block = "172.22.20.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

