terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "1.1.2"
    }
  }
}

resource "auth0_client" "frontend" {
  name     = "guesstimate-app${var.suffix}"
  app_type = "regular_web"
  sso      = true
  callbacks = [
    "${var.frontend_url}/", "${var.frontend_url}/auth-redirect", "${var.frontend_url}/api/auth/callback/auth0"
  ]

  allowed_logout_urls = [var.frontend_url]

  web_origins = [var.frontend_url]

  jwt_configuration {
    alg = "RS256"
  }

  oidc_conformant = true
}

resource "auth0_resource_server" "backend" {
  name       = "guesstimate-backend${var.suffix}"
  identifier = var.backend_url
}

