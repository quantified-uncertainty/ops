locals {
  frontend_url = "http://localhost:3000"
  backend_url  = "http://localhost:4000"
}

data "onepassword_item" "auth0_dev_client_id" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client ID / Terraform guesstimate-development"
}

data "onepassword_item" "auth0_dev_client_secret" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client Secret / Terraform guesstimate-development"
}

data "onepassword_item" "auth0_prod_client_id" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client ID / Terraform guesstimate"
}

data "onepassword_item" "auth0_prod_client_secret" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client Secret / Terraform guesstimate"
}

provider "auth0" {
  alias         = "dev"
  domain        = "guesstimate-development.auth0.com"
  client_id     = data.onepassword_item.auth0_dev_client_id.password
  client_secret = data.onepassword_item.auth0_dev_client_secret.password
}

provider "auth0" {
  alias         = "prod"
  domain        = var.auth0_domain
  client_id     = data.onepassword_item.auth0_prod_client_id.password
  client_secret = data.onepassword_item.auth0_prod_client_secret.password
}

module "auth0_dev" {
  providers = {
    auth0 = auth0.dev
  }

  source = "./auth0"

  frontend_url     = "http://localhost:3000"
  backend_url      = "http://localhost:4000"
  application_name = "Guesstimate (dev)"
  connection_name  = "Username-Password-Authentication"
}

module "auth0_prod" {
  providers = {
    auth0 = auth0.prod
  }

  source = "./auth0"

  frontend_url    = "https://www.getguesstimate.com"
  backend_url     = "http://guesstimate.herokuapp.com"
  connection_name = var.auth0_connection_name

  jwt_alg         = "HS256"
  oidc_conformant = false
  sso             = false
  app_type        = null
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
    "${local.frontend_url}/", "${local.frontend_url}/auth-redirect", "${local.frontend_url}/api/auth/callback/auth0"
  ]

  allowed_logout_urls = [local.frontend_url]
  allowed_origins     = [each.key == "2023" ? local.frontend_url : "${local.frontend_url}/"]
  web_origins         = [local.frontend_url]

  jwt_configuration {
    alg = "RS256"
  }

  oidc_conformant = true
}

