terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "stacks/staging.tfstate"
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

    null = {
      source = "hashicorp/null"
    }
  }
}

module "providers" {
  source = "../../modules/providers"
}

provider "onepassword" {
  # Configuration comes from module.providers
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

provider "vercel" {
  api_token = module.providers.vercel_api_token
  team      = module.providers.vercel_team
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.staging.endpoint
  token                  = digitalocean_kubernetes_cluster.staging.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.staging.kube_config[0].cluster_ca_certificate)
}

data "onepassword_item" "github_token_quri" {
  vault = module.providers.op_vault
  title = "GitHub token for ops"
}

provider "github" {
  token = data.onepassword_item.github_token_quri.password
  owner = "quantified-uncertainty"
}
