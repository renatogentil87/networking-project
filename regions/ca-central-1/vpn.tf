locals {
  vpn-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}

resource "aws_customer_gateway" "ec2-us-east-1" {
  bgp_asn    = 65001
  ip_address = "34.204.204.62"
  type       = "ipsec.1"
  tags = merge(local.vpn-tags, {
    Name = "us-east-1 vpn customer gateway"
  })
}
resource "aws_vpn_connection" "vpn-to-canada" {
  customer_gateway_id = aws_customer_gateway.ec2-us-east-1.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  type                = aws_customer_gateway.ec2-us-east-1.type
  static_routes_only  = false
  tags = merge(local.vpn-tags, {
    Name = "vpn to Canada TGW ${aws_ec2_transit_gateway.main.id}"
  })
  # Tunnel 1 Configuration
  tunnel1_inside_cidr   = "169.254.131.204/30"
  tunnel1_preshared_key = "cl2At.ZzPGS2ksZ08S.3nACEen60Z9VV"

  # Phase 1 (IKE) Configuration
  tunnel1_ike_versions                 = ["ikev1"]
  tunnel1_phase1_encryption_algorithms = ["AES128"]
  tunnel1_phase1_integrity_algorithms  = ["SHA1"]
  tunnel1_phase1_dh_group_numbers      = ["14"]
  tunnel1_phase1_lifetime_seconds      = 28800

  # Phase 2 (IPsec) Configuration
  tunnel1_phase2_encryption_algorithms = ["AES128"]
  tunnel1_phase2_integrity_algorithms  = ["SHA1"]
  tunnel1_phase2_dh_group_numbers      = ["14"]
  tunnel1_phase2_lifetime_seconds      = 3600

  # DPD Configuration
  tunnel1_dpd_timeout_action  = "restart"
  tunnel1_dpd_timeout_seconds = 30
}
