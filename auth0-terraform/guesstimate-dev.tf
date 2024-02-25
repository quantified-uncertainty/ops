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

provider "auth0" {
  domain        = "guesstimate-development.auth0.com"
  client_id     = data.onepassword_item.auth0_dev_client_id.password
  client_secret = data.onepassword_item.auth0_dev_client_secret.password
}

resource "auth0_client" "guesstimate_frontend" {
  name     = "guesstimate-app/dev"
  app_type = "regular_web"
  sso      = true
  callbacks = [
    "${local.frontend_url}/", "${local.frontend_url}/auth-redirect", "${local.frontend_url}/api/auth/callback/auth0"
  ]

  allowed_logout_urls = [local.frontend_url]

  web_origins = [local.frontend_url]

  jwt_configuration {
    alg = "RS256"
  }

  oidc_conformant = true
}

resource "auth0_resource_server" "guesstimate_backend" {
  name       = "guesstimate-backend/dev"
  identifier = local.backend_url
}

# To be imported and deleted
resource "auth0_client" "legacy_guesstimate_client" {
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
