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

  environment = [
    {
      key    = "NEXTAUTH_SECRET"
      value  = random_password.nextauth_secret.result
      target = ["production", "preview"]
    },
    {
      key    = "NEXT_PUBLIC_BASE_URL"
      value  = "https://www.getguesstimate.com"
      target = ["production"]
    },
    {
      key    = "NEXT_PUBLIC_API_BASE_URL"
      value  = "https://${var.api_domain}"
      target = ["production", "preview"]
    },
    {
      key    = "AUTH0_CLIENT_ID"
      value  = module.auth0_2024.client_id
      target = ["production", "preview"]
    },
    {
      key    = "AUTH0_CLIENT_SECRET"
      value  = module.auth0_2024.client_secret
      target = ["production", "preview"]
    },
    {
      key    = "AUTH0_DOMAIN"
      value  = "https://${var.auth0_domain}"
      target = ["production", "preview"]
    },
    {
      key    = "NEXT_PUBLIC_SENTRY_DSN"
      value  = data.sentry_key.main.dsn_public
      target = ["production", "preview"]
    },
    {
      key    = "SENTRY_ORG"
      value  = sentry_project.main.organization
      target = ["production", "preview"]
    },
    {
      key    = "SENTRY_PROJECT"
      value  = sentry_project.main.id
      target = ["production", "preview"]
    },
    {
      key    = "SENTRY_AUTH_TOKEN"
      value  = data.onepassword_item.sentry_auth_token.password
      target = ["production", "preview"]
    },
  ]
}

module "domain" {
  source = "../../modules/vercel-domain"

  domain        = "getguesstimate.com"
  project_id    = vercel_project.frontend.id
  ttl           = 60 # TODO - roll back after we're sure that new Guesstimate works fine
  create_domain = false
}
