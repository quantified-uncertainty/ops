terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  # Previously tried for state management:
  # 1. Local state - impossible to share with the team.
  # 2. Terraform Cloud - slow, feature-incomplete, proprietary.
  # 3. Spacelift with Spacelift-managed state - expensive for 3+ users, no Slack notifications on free plan, too many features for our current needs.
  backend "s3" {
    region         = "us-east-1"
    bucket         = "berekuk-tf-state-us-east-1"
    key            = "quri.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
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

    # Configured in db.tf
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
