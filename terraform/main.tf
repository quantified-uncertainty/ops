terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  cloud {
    organization = "quantified-uncertainty"
    workspaces {
      name = "ops"
    }
  }

  required_providers {
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

    // configured in db.tf
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.20"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "vercel" {
  api_token = var.vercel_api_token
  team      = "quantified-uncertainty"
}

provider "github" {
  token = var.github_token
  owner = "quantified-uncertainty"
}

provider "heroku" {
  api_key = var.heroku_api_key
}
