locals {
  clientvpn-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}

resource "aws_ec2_client_vpn_endpoint" "clientvpn" {
  tags = merge(local.clientvpn-tags, {
    Name = "ClientVPN Endpoint"
  })
  split_tunnel = true
  connection_log_options {
    enabled = false
  }
  client_cidr_block      = "10.10.0.0/16"
  description            = "ClientVPN Endpoint"
  server_certificate_arn = "arn:aws:acm:ca-central-1:223318879912:certificate/69f1eaf8-f519-4b9f-b135-934fd000e721"
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:ca-central-1:223318879912:certificate/04e4bcb8-17a7-485d-8c17-215d9f9bb92b"
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "authorize-remote-connection" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  target_network_cidr    = "10.10.0.0/16"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_authorization_rule" "authorize-vpc-b" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  target_network_cidr    = "172.18.0.0/16"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_authorization_rule" "authorize-vpc-c" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  target_network_cidr    = "172.20.0.0/16"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_authorization_rule" "authorize-shared-vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  target_network_cidr    = "172.22.0.0/16"
  authorize_all_groups   = true
}


resource "aws_ec2_client_vpn_network_association" "shared-vpc-association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  subnet_id              = aws_subnet.private_subnet.id
}

resource "aws_ec2_client_vpn_route" "to-vpc-a" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  destination_cidr_block = "172.16.0.0/16"
  target_vpc_subnet_id   = aws_subnet.private_subnet.id
}

resource "aws_ec2_client_vpn_route" "to-vpc-b" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  destination_cidr_block = "172.18.0.0/16"
  target_vpc_subnet_id   = aws_subnet.private_subnet.id
}

resource "aws_ec2_client_vpn_route" "to-vpc-c" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.clientvpn.id
  destination_cidr_block = "172.20.0.0/16"
  target_vpc_subnet_id   = aws_subnet.private_subnet.id
}
