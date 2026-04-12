
locals {
  r53-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}

locals {
  vpc_ids = [
    aws_vpc.shared_vpc.id,
    module.vpc-a.vpc_id,
    module.vpc-b.vpc_id,
    module.vpc-c.vpc_id
  ]
}

resource "aws_route53_zone" "rrdog_private_com" {
  name = "rrdog.private.com"
  dynamic "vpc" {
    for_each = local.vpc_ids
    content {
      vpc_id = vpc.value
    }
  }
  tags = merge(local.r53-tags, {
    Name = "rrdog.private.com"
  })
}

resource "aws_route53_record" "dev_dns" {
  zone_id = aws_route53_zone.rrdog_private_com.id
  name    = "vpca.rrdog.private.com"
  type    = "A"
  ttl     = "30"
  records = ["1.1.1.1"]
}

resource "aws_route53_record" "vpc_b_dns" {
  zone_id = aws_route53_zone.rrdog_private_com.id
  name    = "vpcb.rrdog.private.com"
  type    = "A"
  ttl     = "30"
  records = ["2.2.2.2"]
}

resource "aws_route53_record" "vpc_c_dns" {
  zone_id = aws_route53_zone.rrdog_private_com.id
  name    = "vpcc.rrdog.private.com"
  type    = "A"
  ttl     = "30"
  records = ["3.3.3.3"]
}


resource "aws_route53_resolver_endpoint" "inbound_to_private_dns_hz" {
  name                   = "rrdog-private-hosted-zone"
  direction              = "INBOUND"
  resolver_endpoint_type = "IPV4"

  security_group_ids = [
    aws_security_group.r53resolver_sg.id
  ]

  ip_address {
    subnet_id = aws_subnet.private_subnet.id
  }

  ip_address {
    subnet_id = aws_subnet.private_subnet.id
    ip        = "172.22.20.254"
  }

  protocols = ["Do53", "DoH"]

  tags = merge(local.r53-tags, { Name = "shared r53 resolver for private hosted zone" })
}

variable "allowed_cidr" {
  default = ["172.16.0.0/16", "172.18.0.0/16", "172.20.0.0/16", "172.31.0.0/16"]

}

resource "aws_security_group" "r53resolver_sg" {
  name        = "allow DNS inbound traffic"
  description = "Allow  DNS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.shared_vpc.id
  tags = merge(local.r53-tags, {
    Name = "r53resolver-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_dns" {
  for_each          = toset(var.allowed_cidr)
  security_group_id = aws_security_group.r53resolver_sg.id
  cidr_ipv4         = each.value
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
  for_each          = toset(var.allowed_cidr)
  security_group_id = aws_security_group.r53resolver_sg.id
  cidr_ipv4         = each.value
  ip_protocol       = "ICMP"
  from_port         = -1
  to_port           = -1
}

resource "aws_route53_resolver_endpoint" "outbound_to_onprem" {
  name      = "outbound-to-onprem-dns"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.r53_outbound_sg.id
  ]
  ip_address {
    subnet_id = aws_subnet.private_subnet.id
  }

  # need to change the subnet here to have a private subnet. It needs to create second subnet in the VPC
  ip_address {
    subnet_id = aws_subnet.public_subnet.id
  }

  tags = merge(local.r53-tags, {
    Name = "outbound-resolver-to-onprem"
  })
}

resource "aws_security_group" "r53_outbound_sg" {
  name        = "r53-outbound-resolver-sg"
  description = "Allow outbound DNS traffic to on-premises DNS servers"
  vpc_id      = aws_vpc.shared_vpc.id

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["172.31.66.165/32"]
  }

  tags = merge(local.r53-tags, {
    Name = "r53-outbound-sg"
  })
}

resource "aws_route53_resolver_rule" "forward_to_onprem" {
  domain_name          = "onprem.example.com"
  name                 = "forward-onprem-domain"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_to_onprem.id

  target_ip {
    ip   = "172.31.66.165"
    port = 53
  }
  tags = merge(local.r53-tags, {
    Name = "forward-to-onprem-rule"
  })
}

resource "aws_route53_resolver_rule" "blocked_domain_forwarding" {
  domain_name          = "blocked.example.com"
  name                 = "forward-blocked-domain"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_to_onprem.id

  target_ip {
    ip   = "172.31.66.165"
    port = 53
  }
  tags = merge(local.r53-tags, {
    Name = "forward-to-onprem-rule"
  })
}


resource "aws_route53_resolver_rule_association" "onprem_forwarding_association" {
  for_each = toset([
    aws_vpc.shared_vpc.id,
    module.vpc-a.vpc_id,
    module.vpc-b.vpc_id,
    module.vpc-c.vpc_id
  ])
  resolver_rule_id = aws_route53_resolver_rule.forward_to_onprem.id
  vpc_id           = each.value
}


resource "aws_route53_resolver_rule_association" "blocked_domain_association" {
  for_each = toset([
    aws_vpc.shared_vpc.id,
    module.vpc-a.vpc_id,
    module.vpc-b.vpc_id,
    module.vpc-c.vpc_id
  ])
  resolver_rule_id = aws_route53_resolver_rule.blocked_domain_forwarding.id
  vpc_id           = each.value
}

resource "aws_route53_resolver_firewall_domain_list" "block_example_domain_list" {
  name    = "block domain"
  domains = ["block.example.com"]
    tags = merge(local.r53-tags, {
    Name = "block-example-com-rule"
  })
}

resource "aws_route53_resolver_firewall_rule_group" "fw_rule_group" {
  name = "firewall-rule-group"
  tags = merge(local.r53-tags, {
    Name = "fw-rule-to-block-example-domain"
  })
}

resource "aws_route53_resolver_firewall_rule" "block_example_com_rule" {
  name                    = "block-example-com-rule"
  action                  = "BLOCK"
  block_override_dns_type = "CNAME"
  block_override_domain   = "example.com"
  block_override_ttl      = 1
  block_response          = "OVERRIDE"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.block_example_domain_list.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.fw_rule_group.id
  priority                = 100
}


resource "aws_route53_resolver_firewall_rule_group_association" "shared_vpc_association" {
  name                   = "shared_vpc_fw_association"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.fw_rule_group.id
  priority               = 200
  vpc_id                 = aws_vpc.shared_vpc.id
  tags = merge(local.r53-tags, {
    Name = "shared-vpc-fw-association"
  } )
}