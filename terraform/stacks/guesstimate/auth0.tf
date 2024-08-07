locals {
  frontend_url = "https://www.getguesstimate.com"
  api_audience = "guesstimate-api"
}

data "onepassword_item" "auth0_prod_client_id" {
  vault = module.providers.op_vault
  title = "Auth0 Client ID / Terraform guesstimate"
}

data "onepassword_item" "auth0_prod_client_secret" {
  vault = module.providers.op_vault
  title = "Auth0 Client Secret / Terraform guesstimate"
}

provider "auth0" {
  alias         = "prod"
  domain        = var.auth0_domain
  client_id     = data.onepassword_item.auth0_prod_client_id.password
  client_secret = data.onepassword_item.auth0_prod_client_secret.password
}

module "auth0_2024" {
  providers = {
    auth0 = auth0.prod
  }

  source = "./auth0"

  frontend_url    = local.frontend_url
  api_audience    = local.api_audience
  connection_name = var.auth0_connection_name
}
