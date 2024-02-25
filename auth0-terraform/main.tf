terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "auth0.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "1.4.1"
    }

    auth0 = {
      source  = "auth0/auth0"
      version = "1.1.2"
    }

  }
}

provider "onepassword" {
  account = "team-quri.1password.com"
}

data "onepassword_vault" "main" {
  name = "Infra"
}
