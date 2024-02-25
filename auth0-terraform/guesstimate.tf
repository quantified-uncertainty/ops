locals {
  frontend_url = "http://localhost:3000"
  backend_url  = "http://localhost:4000"
}

data "onepassword_item" "auth0_dev_client_id" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client ID - guesstimate-development"
}

data "onepassword_item" "auth0_dev_client_secret" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client Secret - guesstimate-development"
}

data "onepassword_item" "auth0_prod_client_id" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client ID - guesstimate"
}

data "onepassword_item" "auth0_prod_client_secret" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 Client Secret - guesstimate"
}

provider "auth0" {
  alias         = "dev"
  domain        = "guesstimate-development.auth0.com"
  client_id     = data.onepassword_item.auth0_dev_client_id.password
  client_secret = data.onepassword_item.auth0_dev_client_secret.password
}

provider "auth0" {
  alias         = "prod"
  domain        = "guesstimate.auth0.com"
  client_id     = data.onepassword_item.auth0_prod_client_id.password
  client_secret = data.onepassword_item.auth0_prod_client_secret.password
}

module "guesstimate_dev" {
  providers = {
    auth0 = auth0.dev
  }

  source = "./guesstimate"

  frontend_url     = "http://localhost:3000"
  backend_url      = "http://localhost:4000"
  application_name = "Guesstimate (dev)"
}

module "guesstimate_prod" {
  providers = {
    auth0 = auth0.prod
  }

  source = "./guesstimate"

  frontend_url = "https://www.getguesstimate.com"
  backend_url  = "http://guesstimate.herokuapp.com"

  jwt_alg         = "HS256"
  oidc_conformant = false
  sso             = false
  app_type        = null
}


moved {
  from = auth0_resource_server.guesstimate_backend
  to   = module.guesstimate_dev.auth0_resource_server.backend
}

moved {
  from = auth0_client.guesstimate_frontend
  to   = module.guesstimate_dev.auth0_client.frontend
}

# Imported to be deleted after Terraform migration is complete
resource "auth0_client" "legacy_guesstimate_client" {
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
