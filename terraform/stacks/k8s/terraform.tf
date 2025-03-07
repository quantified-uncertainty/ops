terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "stacks/secrets-for-k8s.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }

  required_providers {
    onepassword  = { source = "1Password/onepassword" }
    kubernetes   = { source = "hashicorp/kubernetes" }
    digitalocean = { source = "digitalocean/digitalocean" }
    github       = { source = "integrations/github" }
    harbor       = { source = "goharbor/harbor" }
  }
}

module "providers" {
  source = "../../modules/providers"
}

provider "onepassword" {
  account = module.providers.op_account
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "onepassword_item" "do_spaces_api_key" {
  vault = module.providers.op_vault
  title = "DigitalOcean Spaces API Key"
}

provider "digitalocean" {
  token = module.providers.do_token

  spaces_access_id  = data.onepassword_item.do_spaces_api_key.username
  spaces_secret_key = data.onepassword_item.do_spaces_api_key.password
}

data "onepassword_item" "github_token" {
  vault = module.providers.op_vault
  title = "GitHub token"
}

data "onepassword_item" "harbor_password" {
  vault = module.providers.op_vault
  title = "Harbor admin"
}

provider "github" {
  token = data.onepassword_item.github_token.password
  owner = "quantified-uncertainty"
}

provider "harbor" {
  url      = "https://harbor.k8s.quantifieduncertainty.org"
  username = "admin"
  password = data.onepassword_item.harbor_password.password
}
