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

# Legacy - will be replaced soon
module "auth0_prod" {
  providers = {
    auth0 = auth0.prod
  }

  source = "./auth0"

  frontend_url    = local.frontend_url
  api_audience    = null # old prod configuration didn't use audience, it relied on id tokens
  connection_name = var.auth0_connection_name

  jwt_alg         = "HS256"
  oidc_conformant = false
  sso             = false
  app_type        = null
}

module "auth0_2024" {
  providers = {
    auth0 = auth0.prod
  }

  source = "./auth0"

  frontend_url        = local.frontend_url
  api_audience        = local.api_audience
  connection_name     = null # configured in auth0_prod, should be moved
}
