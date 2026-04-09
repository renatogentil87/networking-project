
locals {
  r53-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}


resource "aws_route53_zone" "rrdog_private_com" {
  name = "rrdog.private.com"
  vpc {
    vpc_id = aws_vpc.shared_vpc.id
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
    name = "vpcb.rrdog.private.com"
    type = "A"
    ttl = "30"
    records = ["2.2.2.2"]
}

resource "aws_route53_record" "vpc_c_dns" {
    zone_id = aws_route53_zone.rrdog_private_com.id
    name = "vpcc.rrdog.private.com"
    type = "A"
    ttl = "30"
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

  tags = merge(local.r53-tags, { Name = "shared r53 resolver for private hosted zone"})
}

variable "allowed_cidr" {
  default = ["172.16.0.0/16","172.18.0.0/16","172.20.0.0/16","172.31.0.0/16"]
  
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
  for_each = toset(var.allowed_cidr)
  security_group_id = aws_security_group.r53resolver_sg.id
  cidr_ipv4 = each.value
  ip_protocol =  "udp"
  from_port = 53
  to_port = 53
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
  for_each = toset(var.allowed_cidr)
  security_group_id = aws_security_group.r53resolver_sg.id
  cidr_ipv4 = each.value
  ip_protocol =  "ICMP"
  from_port = -1
  to_port = -1
}

locals {
  vpc_ids = [
    module.vpc-a.vpc_id,
    module.vpc-b.vpc_id,
    module.vpc-c.vpc_id
  ]
}

resource "aws_route53_zone_association" "vpc_a" {
  for_each = toset(local.vpc_ids)
  zone_id = aws_route53_zone.rrdog_private_com.id
  vpc_id  = each.value
}