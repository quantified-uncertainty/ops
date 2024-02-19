resource "vercel_project" "hub" {
  name           = "quri-hub"
  root_directory = "packages/hub"
  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }

  environment = [
    {
      key = "DATABASE_URL"
      // https://www.prisma.io/docs/guides/performance-and-optimization/connection-management/configure-pg-bouncer#add-pgbouncer-to-the-connection-url
      value  = "${module.prod_db.bouncer_url}&pgbouncer=true"
      target = ["production"]
    },
    {
      key    = "DATABASE_URL"
      value  = "${module.dev_db.bouncer_url}&pgbouncer=true"
      target = ["preview"]
    },
    {
      key    = "ROOT_EMAILS"
      value  = var.hub_root_emails
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

module "squiggle_hub_domain" {
  source = "./vercel-domain"

  domain     = "squigglehub.org"
  project_id = vercel_project.hub.id
  www        = false
}

moved {
  from = vercel_project_domain.squigglehub-org
  to   = module.squiggle_hub_domain.vercel_project_domain.main
}

moved {
  from = vercel_project_domain.squigglehub-redirects["www.squigglehub.org"]
  to   = module.squiggle_hub_domain.vercel_project_domain.www_redirect
}

module "squiggle_hub_alternative_domains" {
  source = "./vercel-domain"

  for_each = toset([
    "squigglehub.com",
    "squiggle-hub.org",
    "squiglge-hub.com"
  ])

  domain     = each.key
  redirect   = "squigglehub.org"
  project_id = vercel_project.hub.id
  www        = false
}

moved {
  from = vercel_project_domain.squigglehub-redirects["squigglehub.com"]
  to   = module.squiggle_hub_alternative_domains["squigglehub.com"].main
}

moved {
  from = vercel_project_domain.squigglehub-redirects["www.squigglehub.com"]
  to   = module.squiggle_hub_alternative_domains["squigglehub.com"].www_redirect
}

moved {
  from = vercel_project_domain.squigglehub-redirects["squiggle-hub.org"]
  to   = module.squiggle_hub_alternative_domains["squiggle-hub.org"].main
}

moved {
  from = vercel_project_domain.squigglehub-redirects["www.squiggle-hub.org"]
  to   = module.squiggle_hub_alternative_domains["squiggle-hub.org"].www_redirect
}

moved {
  from = vercel_project_domain.squigglehub-redirects["squiggle-hub.com"]
  to   = module.squiggle_hub_alternative_domains["squiggle-hub.com"].main
}

moved {
  from = vercel_project_domain.squigglehub-redirects["www.squiggle-hub.com"]
  to   = module.squiggle_hub_alternative_domains["squiggle-hub.com"].www_redirect
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
