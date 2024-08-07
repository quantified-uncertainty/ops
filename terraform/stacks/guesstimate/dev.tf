# Some cloud services necessary for running the default dev configuration.

locals {
  dev_frontend_url = "http://localhost:3000"
}

data "onepassword_item" "auth0_dev_client_id" {
  vault = module.providers.op_vault
  title = "Auth0 Client ID / Terraform guesstimate-development"
}

data "onepassword_item" "auth0_dev_client_secret" {
  vault = module.providers.op_vault
  title = "Auth0 Client Secret / Terraform guesstimate-development"
}

provider "auth0" {
  alias         = "dev"
  domain        = "guesstimate-development.auth0.com"
  client_id     = data.onepassword_item.auth0_dev_client_id.password
  client_secret = data.onepassword_item.auth0_dev_client_secret.password
}

module "auth0_dev" {
  providers = {
    auth0 = auth0.dev
  }

  source = "./auth0"

  frontend_url     = local.dev_frontend_url
  api_audience     = local.api_audience # same for dev and for prod
  application_name = "Guesstimate (dev)"
  connection_name  = "Username-Password-Authentication"
}
