# Vercel project for the Next.js frontend
resource "vercel_project" "main" {
  name      = "roast-my-post"
  framework = "nextjs"

  git_repository = {
    type = "github"
    repo = "quantified-uncertainty/roast-my-post"
  }

  root_directory = "apps/web"
  install_command = "pnpm install"
  
  # Environment variables for Vercel deployment
  environment = [
    {
      key    = "ENABLE_EXPERIMENTAL_COREPACK"
      value  = "1"
      target = ["production", "preview", "development"]
    },
    {
      key    = "NEXT_PUBLIC_SITE_URL"
      value  = "https://www.${local.domain}"
      target = ["production", "preview", "development"]
    },
    {
      key    = "DATABASE_URL"
      value  = module.database.bouncer_url
      target = ["production", "preview", "development"]
    },
    {
      key    = "AUTH_SECRET"
      value  = data.onepassword_item.auth_secret.password
      target = ["production", "preview", "development"]
    },
    {
      key    = "NEXTAUTH_URL"
      value  = "https://www.${local.domain}"
      target = ["production", "preview", "development"]
    },
    {
      key    = "ANTHROPIC_API_KEY"
      value  = data.onepassword_item.anthropic_api_key.password
      target = ["production", "preview", "development"]
    },
    {
      key    = "OPENROUTER_API_KEY"
      value  = data.onepassword_item.openrouter_api_key.password
      target = ["production", "preview", "development"]
    },
    {
      key    = "FIRECRAWL_KEY"
      value  = data.onepassword_item.firecrawl_key.password
      target = ["production", "preview", "development"]
    },
    {
      key    = "SENDGRID_KEY"
      value  = data.onepassword_item.sendgrid_key.password
      target = ["production", "preview", "development"]
    },
    {
      key    = "EMAIL_FROM"
      value  = "noreply@${local.domain}"
      target = ["production", "preview", "development"]
    },
    {
      key    = "AUTH_RESEND_KEY"
      value  = data.onepassword_item.auth_resend_key.password
      target = ["production", "preview", "development"]
    },
    {
      key    = "AUTH_TRUST_HOST"
      value  = "true"
      target = ["production", "preview", "development"]
    },
    {
      key    = "HELICONE_API_KEY"
      value  = data.onepassword_item.helicone_api_key.password
      target = ["production", "preview", "development"]
    },
    {
      key    = "DIFFBOT_KEY"
      value  = data.onepassword_item.diffbot_key.password
      target = ["production", "preview", "development"]
    }
  ]
}

# Domain configuration using the vercel-domain module
module "domain" {
  source = "../../modules/vercel-domain"

  domain     = local.domain
  project_id = vercel_project.main.id
  www        = true  # Create www subdomain redirect
}

# Associate domain with DigitalOcean project
resource "digitalocean_project_resources" "domain" {
  project   = digitalocean_project.main.id
  resources = module.domain.digitalocean_urns
}