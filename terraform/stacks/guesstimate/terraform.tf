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
      source = "1Password/onepassword"
    }

    auth0 = {
      source = "auth0/auth0"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
    }

    vercel = {
      source = "vercel/vercel"
    }

    github = {
      source = "integrations/github"
    }

    sentry = {
      # Not official, but blessed by Sentry; https://blog.sentry.io/introducing-terraform-for-sentry/
      source = "jianyuan/sentry"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
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

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "onepassword_item" "github_token_getguesstimate" {
  vault = module.providers.op_vault
  title = "GitHub token for getguesstimate"
}

provider "github" {
  token = data.onepassword_item.github_token_getguesstimate.password
  owner = "getguesstimate"
}
