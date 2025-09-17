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
  
  # Workaround for provider bug
  enable_affected_projects_deployments = false
  
  # Keep current authentication settings
  vercel_authentication = {
    deployment_type = "none"
  }
  
  # Environment variables for Vercel deployment
  environment = [
    {
      key    = "ENABLE_EXPERIMENTAL_COREPACK"
      value  = "1"
      target = ["production", "preview"]
    },
    # Only set for production - preview will use Vercel's system variables
    {
      key    = "NEXT_PUBLIC_SITE_URL"
      value  = "https://www.${local.domain}"
      target = ["production"]
    },
    {
      key    = "DATABASE_URL"
      value  = module.database.bouncer_url
      target = ["production", "preview"]
    },
    {
      key    = "AUTH_SECRET"
      value  = data.onepassword_item.auth_secret.password
      target = ["production", "preview"]
    },
    # Only set for production - NextAuth will use VERCEL_URL automatically for preview
    {
      key    = "NEXTAUTH_URL"
      value  = "https://www.${local.domain}"
      target = ["production"]
    },
    # Staging environment configuration
    {
      key    = "NEXT_PUBLIC_SITE_URL"
      value  = "https://staging.${local.domain}"
      target = ["development"]
    },
    {
      key    = "NEXTAUTH_URL"
      value  = "https://staging.${local.domain}"
      target = ["development"]
    },
    {
      key    = "DATABASE_URL"
      value  = module.staging_database.bouncer_url
      target = ["development"]
    },
    {
      key    = "EMAIL_FROM"
      value  = "noreply-staging@${local.domain}"
      target = ["development"]
    },
    {
      key    = "ANTHROPIC_API_KEY"
      value  = data.onepassword_item.anthropic_api_key.password
      target = ["production", "preview"]
    },
    {
      key    = "OPENROUTER_API_KEY"
      value  = data.onepassword_item.openrouter_api_key.password
      target = ["production", "preview"]
    },
    {
      key    = "FIRECRAWL_KEY"
      value  = data.onepassword_item.firecrawl_key.password
      target = ["production", "preview"]
    },
    {
      key    = "SENDGRID_KEY"
      value  = data.onepassword_item.sendgrid_key.password
      target = ["production", "preview"]
    },
    {
      key    = "EMAIL_FROM"
      value  = "noreply@${local.domain}"
      target = ["production", "preview"]
    },
    {
      key    = "AUTH_RESEND_KEY"
      value  = data.onepassword_item.auth_resend_key.password
      target = ["production", "preview"]
    },
    {
      key    = "AUTH_TRUST_HOST"
      value  = "true"
      target = ["production", "preview"]
    },
    {
      key    = "HELICONE_API_KEY"
      value  = data.onepassword_item.helicone_api_key.password
      target = ["production", "preview"]
    },
    {
      key    = "DIFFBOT_KEY"
      value  = data.onepassword_item.diffbot_key.password
      target = ["production", "preview"]
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

# Staging subdomain for staging branch deployments
resource "vercel_project_domain" "staging" {
  project_id = vercel_project.main.id
  domain     = "staging.${local.domain}"
  git_branch = "staging"
}

# Associate domain with DigitalOcean project
resource "digitalocean_project_resources" "domain" {
  project   = digitalocean_project.main.id
  resources = module.domain.digitalocean_urns
}
