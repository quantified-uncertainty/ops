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
    onepassword = {
      source  = "1Password/onepassword"
      version = "1.4.1"
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

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "onepassword_vault" "main" {
  name = "Infra"
}

data "onepassword_item" "grafana_admin" {
  vault = data.onepassword_vault.main.uuid
  title = "Grafana admin"
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-credentials" # must be in sync with `k8s/apps/prometheus/values.yaml`
    namespace = "prometheus"          # must be in sync with `k8s/app-manifests/prometheus-stack.yaml`
  }

  data = {
    admin-user     = data.onepassword_item.grafana_admin.username
    admin-password = data.onepassword_item.grafana_admin.password
  }
}
