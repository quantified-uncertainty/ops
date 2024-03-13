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

provider "onepassword" {
  account = "team-quri.1password.com"
}

data "onepassword_vault" "main" {
  name = "Infra"
}

// TODO - copy-pasted between stacks
// DigitalOcan token
// Get here: https://cloud.digitalocean.com/account/api/tokens
data "onepassword_item" "do_token" {
  vault = data.onepassword_vault.main.uuid
  title = "DigitalOcean token"
}
// Vercel API token
// Get here: https://vercel.com/account/tokens
data "onepassword_item" "vercel_api_token" {
  vault = data.onepassword_vault.main.uuid
  title = "Vercel API token"
}

provider "digitalocean" {
  token = data.onepassword_item.do_token.password
}

provider "vercel" {
  api_token = data.onepassword_item.vercel_api_token.password
  team      = "quantified-uncertainty"
}

data "onepassword_item" "sentry" {
  vault = data.onepassword_vault.main.uuid
  title = "Sentry root token"
}

provider "sentry" {
  token = data.onepassword_item.sentry.password
}

// Get through `heroku authorizations:create` in CLI.
// Note: Heroku tokens are global!
data "onepassword_item" "heroku_api_key" {
  vault = data.onepassword_vault.main.uuid
  title = "Heroku API key"
}

provider "heroku" {
  api_key = data.onepassword_item.heroku_api_key.password
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
