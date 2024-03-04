resource "random_password" "nextauth_secret" {
  length = 44
}

resource "vercel_project" "frontend" {
  name      = "guesstimate-app"
  framework = "nextjs"

  git_repository = {
    type              = "github"
    repo              = "berekuk/guesstimate-app"
    production_branch = "2024"
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
  ]
}

# frontend; note that `api.getguesstimate.com` is managed by DigitalOcean (see `domain` block in `backend.tf`)
# TODO - when we deploy this as prod, we can switch to `vercel-domain` module.
resource "digitalocean_record" "next" {
  domain = digitalocean_domain.main.id
  name   = "next"
  type   = "CNAME"
  value  = "cname.vercel-dns.com."
}

resource "vercel_project_domain" "next" {
  project_id = vercel_project.frontend.id
  domain     = digitalocean_record.next.fqdn
}
