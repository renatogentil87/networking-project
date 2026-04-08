terraform {
    backend "s3" {
        bucket = "rrdog-ca-central-1-backend"
        key = "ca-central-1/terraform.tfstate"
        region = "us-east-1"
      
    }
}