terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "stacks/guesstimate.tfstate"
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

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.34.1"
    }

    vercel = {
      source  = "vercel/vercel"
    }

    heroku = {
      source  = "heroku/heroku"
      version = "5.2.8"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }

    sentry = {
      # Not official, but blessed by Sentry; https://blog.sentry.io/introducing-terraform-for-sentry/
      source  = "jianyuan/sentry"
      version = "0.12.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
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

provider "sentry" {
  token = module.providers.sentry_token
}

provider "heroku" {
  api_key = module.providers.heroku_api_key
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
