locals {
  dx-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

resource "aws_dx_gateway" "dxgw" {
  name            = "dx gateway emea-labs"
  amazon_side_asn = "64910"

}

resource "aws_dx_hosted_private_virtual_interface_accepter" "accept_vif" {
  provider = aws.ireland
  virtual_interface_id = "dxvif-fhasjvgq"  
  dx_gateway_id        = aws_dx_gateway.dxgw.id
  tags = merge(local.dx-tags, {
    Name = "Accepter VIF EMEA LABs"
  })
}

resource "aws_dx_gateway_association" "dxgw_tgw_association" {
  dx_gateway_id         = aws_dx_gateway.dxgw.id
  associated_gateway_id = aws_ec2_transit_gateway.main.id
  allowed_prefixes      = ["10.10.0.0/16","10.20.0.0/16","10.30.0.0/16","10.40.0.0/16"]
}

