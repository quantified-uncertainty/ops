terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "1.1.2"
    }
  }
}

resource "auth0_client" "frontend" {
  name     = var.application_name
  app_type = var.app_type
  callbacks = [
    "${var.frontend_url}/", "${var.frontend_url}/auth-redirect", "${var.frontend_url}/api/auth/callback/auth0"
  ]

  allowed_logout_urls = [var.frontend_url]

  web_origins = [var.frontend_url]

  jwt_configuration {
    alg = var.jwt_alg
  }

  oidc_conformant = var.oidc_conformant
  sso             = var.sso
}

resource "auth0_client_credentials" "frontend" {
  client_id             = auth0_client.frontend.client_id
  authentication_method = "client_secret_post"
}

resource "auth0_resource_server" "backend" {
  name       = "Guesstimate API"
  identifier = var.backend_url

  signing_alg   = var.jwt_alg
  token_dialect = "access_token"
}

resource "auth0_connection" "main" {
  name     = var.connection_name
  strategy = "auth0"
}
