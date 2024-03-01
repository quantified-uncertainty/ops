terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "main.tfstate"
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

    heroku = {
      source  = "heroku/heroku"
      version = "5.2.8"
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

provider "onepassword" {
  account = "team-quri.1password.com"
}

data "onepassword_vault" "main" {
  name = "Infra"
}

provider "digitalocean" {
  token = data.onepassword_item.do_token.password
}

provider "vercel" {
  api_token = data.onepassword_item.vercel_api_token.password
  team      = "quantified-uncertainty"
}

provider "github" {
  token = data.onepassword_item.github_token.password
  owner = "quantified-uncertainty"
}

provider "heroku" {
  api_key = data.onepassword_item.heroku_api_key.password
}
