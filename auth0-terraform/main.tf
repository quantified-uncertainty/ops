terraform {
  # Last open source Terraform version.
  # Please don't update it; we might migrate to OpenTofu in the future.
  required_version = "1.5.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "auth0.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "1.4.1"
    }

    auth0 = {
      source  = "auth0/auth0"
      version = "1.1.2"
    }

  }
}

provider "onepassword" {
  account = "team-quri.1password.com"
}

data "onepassword_vault" "main" {
  name = "Infra"
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
    "http://localhost:3000/", "http://localhost:3000/auth-redirect", "http://localhost:3000/api/auth/callback/auth0"
  ]

  allowed_logout_urls = ["http://localhost:3000"]

  web_origins = ["http://localhost:3000"]

  jwt_configuration {
    alg = "RS256"
  }

  oidc_conformant = true
}

resource "auth0_resource_server" "guesstimate_backend" {
  name       = "guesstimate-backend/dev"
  identifier = "http://localhost:4000"
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
    "http://localhost:3000/", "http://localhost:3000/auth-redirect", "http://localhost:3000/api/auth/callback/auth0"
  ]

  allowed_logout_urls = ["http://localhost:3000"]
  allowed_origins     = [each.key == "2023" ? "http://localhost:3000" : "http://localhost:3000/"]
  web_origins         = ["http://localhost:3000"]

  jwt_configuration {
    alg = "RS256"
  }

  oidc_conformant = true
}
