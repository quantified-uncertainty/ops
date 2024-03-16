terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "stacks/quri.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "1.4.1"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.34.1"
    }

    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.4"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }

    # Configured in db.tf
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.20"
    }
  }
}

module "providers" {
  source = "../../modules/providers"
}

provider "onepassword" {
  account = module.providers.op_account
}

provider "digitalocean" {
  token = module.providers.do_token
}

provider "vercel" {
  api_token = module.providers.vercel_api_token
  team      = module.providers.vercel_team
}

provider "github" {
  token = data.onepassword_item.github_token.password
  owner = "quantified-uncertainty"
}
