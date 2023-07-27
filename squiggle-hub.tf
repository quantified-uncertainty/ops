resource "vercel_project" "hub" {
  name           = "quri-hub"
  root_directory = "packages/hub"
  git_repository = {
    production_branch = "develop"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }

  environment = [
    {
      key    = "DATABASE_URL"
      value  = "${digitalocean_database_connection_pool.main.uri}&pgbouncer=true"
      target = ["production", "preview"]
    },
    {
      key    = "GITHUB_CLIENT_ID"
      value  = var.github_client_id
      target = ["production"]
    },
    {
      key    = "GITHUB_CLIENT_SECRET"
      value  = var.github_client_secret
      target = ["production"]
    },
    {
      key    = "SENDGRID_KEY"
      value  = var.sendgrid_key
      target = ["production", "preview"]
    },
    {
      key    = "EMAIL_FROM"
      value  = var.hub_email_from
      target = ["production", "preview"]
    },
    {
      key    = "NEXTAUTH_SECRET"
      value  = var.hub_nextauth_secret
      target = ["production", "preview"]
    },
  ]

  # close to digitalocean_database_cluster.quri
  serverless_function_region = "iad1"
}

resource "vercel_project_domain" "squigglehub-org" {
  domain     = "squigglehub.org"
  project_id = vercel_project.hub.id
}

resource "vercel_project_domain" "squigglehub-redirects" {
  for_each = toset([
    "www.squigglehub.org",
    "squigglehub.com",
    "www.squigglehub.com",
    "squiggle-hub.org",
    "www.squiggle-hub.org",
    "squiggle-hub.com",
    "www.squiggle-hub.com",
  ])
  domain               = each.key
  redirect             = "squigglehub.org"
  redirect_status_code = 308
  project_id           = vercel_project.hub.id
}

# Sendgrid DNS configuration; obtained from https://app.sendgrid.com/settings/sender_auth/domain/get/18308809
resource "vercel_dns_record" "squigglehub-sendgrid" {
  for_each = {
    "url1940" : "sendgrid.net",
    "34091428" : "sendgrid.net",
    "em6594" : "u34091428.wl179.sendgrid.net",
    "s1._domainkey" : "s1.domainkey.u34091428.wl179.sendgrid.net",
    "s2._domainkey" : "s2.domainkey.u34091428.wl179.sendgrid.net",
  }

  domain = "squigglehub.org"
  name   = each.key
  type   = "CNAME"
  ttl    = 300
  value  = each.value
}
