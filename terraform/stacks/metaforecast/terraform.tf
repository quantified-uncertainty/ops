terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "stacks/metaforecast.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }

  required_providers {
    onepassword  = { source = "1Password/onepassword" }
    digitalocean = { source = "digitalocean/digitalocean" }
    vercel       = { source = "vercel/vercel" }
    heroku       = { source = "heroku/heroku" }
    kubernetes   = { source = "hashicorp/kubernetes" }
  }
}

provider "onepassword" {
  account = module.providers.op_account
}

module "providers" {
  source = "../../modules/providers"
}

provider "digitalocean" {
  token = module.providers.do_token
}

provider "vercel" {
  api_token = module.providers.vercel_api_token
  team      = module.providers.vercel_team_id
}

provider "heroku" {
  api_key = module.providers.heroku_api_key
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
