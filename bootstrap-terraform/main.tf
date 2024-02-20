provider "aws" {
  # sometimes "region" in module vars is not enough
  region = "us-east-1"
}

module "bootstrap" {
  source  = "trussworks/bootstrap/aws"
  version = "5.2.0"

  region               = "us-east-1"
  account_alias        = "quri"
  manage_account_alias = false
}
