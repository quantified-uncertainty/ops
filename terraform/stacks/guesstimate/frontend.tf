locals {
  frontend_env = {
    "NEXTAUTH_SECRET"      = random_password.nextauth_secret.result
    "NEXT_PUBLIC_BASE_URL" = "https://www.getguesstimate.com"
    # "NEXT_PUBLIC_API_BASE_URL" = "https://${var.api_domain}"
    # Temporary, we'll redirect DNS soon
    "NEXT_PUBLIC_API_BASE_URL" = "https://guesstimate-server.k8s.quantifieduncertainty.org"
    "AUTH0_CLIENT_ID"          = module.auth0_2024.client_id
    "AUTH0_CLIENT_SECRET"      = module.auth0_2024.client_secret
    "AUTH0_DOMAIN"             = "https://${var.auth0_domain}"
    "NEXT_PUBLIC_SENTRY_DSN"   = data.sentry_key.main.dsn_public
    "SENTRY_ORG"               = sentry_project.main.organization
    "SENTRY_PROJECT"           = sentry_project.main.id
    "SENTRY_AUTH_TOKEN"        = data.onepassword_item.sentry_auth_token.password
  }
}
resource "random_password" "nextauth_secret" {
  length = 44
}

# Note that is different from "Sentry root token".
# Root token is used to configure Sentry resources, while auth token is used to authenticate from Vercel to upload source maps.
# Auth token has less permissions than root token.
data "onepassword_item" "sentry_auth_token" {
  vault = data.onepassword_vault.main.uuid
  title = "Sentry auth token"
}

resource "vercel_project" "frontend" {
  name      = "guesstimate-app"
  framework = "nextjs"

  git_repository = {
    type              = "github"
    repo              = "getguesstimate/guesstimate-app"
    production_branch = "main"
  }

  environment = concat([
    # TODO - env for preview deployments (but we need to make sure it's safe to expose these env vars to PRs)
    for key, value in local.frontend_env : {
      key    = key
      value  = value
      target = ["production"]
    }
  ])
}

module "domain" {
  source = "../../modules/vercel-domain"

  domain        = "getguesstimate.com"
  project_id    = vercel_project.frontend.id
  ttl           = 60 # TODO - roll back after we're sure that new Guesstimate works fine
  create_domain = false
}
