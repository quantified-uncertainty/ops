# Vercel project for the Next.js frontend
resource "vercel_project" "main" {
  name      = "roast-my-post"
  framework = "nextjs"

  git_repository = {
    type = "github"
    repo = "quantified-uncertainty/roast-my-post"
  }

  build_command    = "npx prisma generate && npm run build"
  output_directory = ".next"
  
  # Environment variables for Vercel deployment
  environment = [
    {
      key    = "NEXT_PUBLIC_SITE_URL"
      value  = "https://www.${local.domain}"
      target = ["production", "preview", "development"]
    },
    {
      key    = "DATABASE_URL"
      value  = module.database.bouncer_url
      target = ["production"]
    },
    {
      key    = "AUTH_SECRET"
      value  = data.onepassword_item.auth_secret.password
      target = ["production"]
    },
    {
      key    = "NEXTAUTH_URL"
      value  = "https://www.${local.domain}"
      target = ["production"]
    },
    {
      key    = "ANTHROPIC_API_KEY"
      value  = data.onepassword_item.anthropic_api_key.password
      target = ["production"]
    },
    {
      key    = "OPENROUTER_API_KEY"
      value  = data.onepassword_item.openrouter_api_key.password
      target = ["production"]
    },
    {
      key    = "FIRECRAWL_KEY"
      value  = data.onepassword_item.firecrawl_key.password
      target = ["production"]
    },
    {
      key    = "SENDGRID_KEY"
      value  = data.onepassword_item.sendgrid_key.password
      target = ["production"]
    },
    {
      key    = "EMAIL_FROM"
      value  = "noreply@${local.domain}"
      target = ["production"]
    },
    {
      key    = "AUTH_RESEND_KEY"
      value  = data.onepassword_item.auth_resend_key.password
      target = ["production"]
    },
    {
      key    = "AUTH_TRUST_HOST"
      value  = "true"
      target = ["production"]
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