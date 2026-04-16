

module "ec2-vpc-a" {
  source          = "../../modules/ec2"
  subnet_id       = module.vpc-a.private_subnet
  vpc_id          = module.vpc-a.vpc_id
  vpc_name        = "vpc-a"
  allowed_cidr    = ["10.20.10.0/24", "10.20.20.0/24", "172.16.0.0/16"]
  key_output_path = path.root
}

module "ec2-vpc-b" {
  source          = "../../modules/ec2"
  subnet_id       = module.vpc-b.private_subnet
  vpc_id          = module.vpc-b.vpc_id
  vpc_name        = "vpc-b"
  allowed_cidr    = ["10.10.10.0/24", "10.10.20.0/24", "172.16.0.0/16"]
  key_output_path = path.root
}

module "ec2-vpc-c" {
  source          = "../../modules/ec2"
  subnet_id       = module.vpc-c.private_subnet
  vpc_id          = module.vpc-c.vpc_id
  vpc_name        = "vpc-c"
  allowed_cidr    = ["10.10.10.0/24", "10.10.20.0/24"]
  key_output_path = path.root
}
module "ec2-shared-vpc" {
  source          = "../../modules/ec2"
  subnet_id       = aws_subnet.private_subnet.id
  vpc_id          = aws_vpc.shared_vpc.id
  vpc_name        = "shared-vpc"
  allowed_cidr    = ["10.10.10.0/24", "10.10.20.0/24", "10.20.10.0/24", "10.20.20.0/24", "10.30.10.0/24", "10.30.20.0/24", "172.22.0.0/16"]
  key_output_path = path.root
}


