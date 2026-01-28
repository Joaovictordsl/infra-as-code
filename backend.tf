terraform {
  backend "s3" {
    bucket       = "s3-bucket-infra-as-code"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

}
