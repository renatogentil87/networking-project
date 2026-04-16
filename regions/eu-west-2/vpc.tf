locals {
  common_tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}
module "vpc-a" {
  source         = "../../modules/networking"
  vpc_cidr       = "10.10.0.0/16"
  vpc_name       = "vpc-a"
  private_subnet = "10.10.20.0/24"
  tags = merge(local.common_tags, {
    Name = "vpc-a"
  })
}
resource "aws_route" "vpc-a-to-vpc-b"{
    destination_cidr_block = "10.20.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    route_table_id = module.vpc-a.private_route_id
}

resource "aws_route" "vpc-a-london-to-vpc-a-canada" {
    destination_cidr_block = "172.16.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    route_table_id = module.vpc-a.private_route_id
}
module "vpc-b" {
  source         = "../../modules/networking"
  vpc_cidr       = "10.20.0.0/16"
  vpc_name       = "vpc-a"
  private_subnet = "10.20.20.0/24"
  tags = merge(local.common_tags, {
    Name = "vpc-b"
  })
}
resource "aws_route" "vpc-b-to-vpc-a"{
    destination_cidr_block = "10.10.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    route_table_id = module.vpc-b.private_route_id
}

resource "aws_route" "vpc-b-london-to-vpc-b-canada" {
    destination_cidr_block = "172.16.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    route_table_id = module.vpc-b.private_route_id
}
module "vpc-c" {
  source         = "../../modules/networking"
  vpc_cidr       = "10.30.0.0/16"
  vpc_name       = "vpc-a"
  private_subnet = "10.30.20.0/24"
  tags = merge(local.common_tags, {
    Name = "vpc-c"
  })
}
resource "aws_route" "vpc-c-to-shared-vpc"{
    destination_cidr_block = "10.40.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    route_table_id = module.vpc-c.private_route_id
}

resource "aws_route" "shared-vpc-london-to-shared-vpc-canada" {
    destination_cidr_block = "172.22.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    route_table_id = aws_route_table.private_route.id
}