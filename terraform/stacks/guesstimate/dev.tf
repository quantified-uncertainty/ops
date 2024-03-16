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

# Imported to be deleted after Terraform migration is complete
resource "auth0_client" "legacy_dev_client" {
  provider = auth0.dev

  for_each = toset([
    "2023",
    "pre-2023"
  ])

  name = "${each.key}, use guesstimate-app/dev instead"

  app_type = each.key == "2023" ? "spa" : "regular_web"
  sso      = each.key == "2023" ? false : true
  callbacks = [
    "${local.dev_frontend_url}/", "${local.dev_frontend_url}/auth-redirect", "${local.dev_frontend_url}/api/auth/callback/auth0"
  ]

  allowed_logout_urls = [local.dev_frontend_url]
  allowed_origins     = [each.key == "2023" ? local.dev_frontend_url : "${local.dev_frontend_url}/"]
  web_origins         = [local.dev_frontend_url]

  jwt_configuration {
    alg = "RS256"
  }

  oidc_conformant = true
}
