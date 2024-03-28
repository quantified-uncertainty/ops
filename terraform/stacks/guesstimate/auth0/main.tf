terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "1.2.0"
    }
  }
}

resource "auth0_client" "frontend" {
  name     = var.application_name
  app_type = var.app_type
  callbacks = flatten([
    for url in local.all_frontend_urls : [
      "${url}/",
      "${url}/auth-redirect",
      "${url}/api/auth/callback/auth0"
    ]
  ])

  allowed_logout_urls = local.all_frontend_urls

  web_origins = local.all_frontend_urls

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
  count      = var.api_audience == null ? 0 : 1
  name       = "Guesstimate API"
  identifier = var.api_audience

  signing_alg                                     = var.jwt_alg
  token_dialect                                   = "access_token"
  skip_consent_for_verifiable_first_party_clients = true
  allow_offline_access                            = true # enable refresh tokens
}

resource "auth0_connection" "main" {
  count    = var.connection_name == null ? 0 : 1
  name     = var.connection_name
  strategy = "auth0"

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  all_frontend_urls = concat([var.frontend_url], var.extra_frontend_urls)
}
