locals {
  squiggle_hub_domain = "squigglehub.org"
}

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

  domain     = local.squiggle_hub_domain
  project_id = vercel_project.hub.id
  www        = false
}

module "squiggle_hub_alternative_domains" {
  source = "./vercel-domain"

  for_each = toset([
    "squigglehub.com",
    "squiggle-hub.org",
    "squiggle-hub.com"
  ])

  domain     = each.key
  redirect   = local.squiggle_hub_domain
  project_id = vercel_project.hub.id
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

  domain = local.squiggle_hub_domain
  name   = each.key
  type   = "CNAME"
  ttl    = 300
  value  = each.value
}

# Sendgrid DNS configuration; obtained from https://app.sendgrid.com/settings/sender_auth/domain/get/18308809
resource "digitalocean_record" "hub-sendgrid" {
  for_each = {
    "url1940" : "sendgrid.net",
    "34091428" : "sendgrid.net",
    "em6594" : "u34091428.wl179.sendgrid.net",
    "s1._domainkey" : "s1.domainkey.u34091428.wl179.sendgrid.net",
    "s2._domainkey" : "s2.domainkey.u34091428.wl179.sendgrid.net",
    "@" : "google-site-verification=Hsd2Gnz5SHJyJYyZMbdZDXzDnYovWfwiF2cWnIBH0C0",
    "@" : "google-site-verification=msJjgrChhh6V0p1pp0c0kj4Q_RdPEWrJk4yhRcN4uE4"
  }

  domain = local.squiggle_hub_domain
  name   = each.key
  type   = "CNAME"
  ttl    = 300
  value  = each.value
}
