
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
  records = [module.ec2-vpc-a.private_ip]
}
