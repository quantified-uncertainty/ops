terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "stacks/roast-my-post.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }

  required_providers {
    onepassword = {
      source = "1Password/onepassword"
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

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    postgresql = {
      source = "cyrilgdn/postgresql"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

module "providers" {
  source = "../../modules/providers"
}

# provider "onepassword" {
#   account = module.providers.op_account
# }

provider "digitalocean" {
  token = module.providers.do_token
}

provider "vercel" {
  api_token = module.providers.vercel_api_token
  team      = module.providers.vercel_team
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "onepassword_item" "github_token_quri" {
  vault = module.providers.op_vault
  title = "GitHub token for ops"
}

provider "github" {
  token = data.onepassword_item.github_token_quri.password
  owner = "quantified-uncertainty"
}