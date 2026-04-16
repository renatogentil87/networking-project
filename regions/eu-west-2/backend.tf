terraform {
  backend "s3" {
    bucket = "rrdog-eu-west-2-backend"
    key    = "eu-west-2/terraform.tfstate"
    region = "us-east-1"

  }
}
