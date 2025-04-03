locals {
  squiggle_hub_domain = "squigglehub.org"
}

resource "random_password" "hub_nextauth_secret" {
  length = 44
}

resource "vercel_project" "hub" {
  name           = "quri-hub"
  root_directory = "apps/hub"
  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }

  environment = [
    {
      key    = "DATABASE_URL"
      value  = data.terraform_remote_state.quri.outputs.prod_db_prisma_url
      target = ["production"]
    },
    {
      key    = "DATABASE_URL"
      value  = data.terraform_remote_state.quri.outputs.dev_db_prisma_url
      target = ["preview"]
    },
    {
      key    = "METAFORECAST_DB_URL"
      value  = data.terraform_remote_state.metaforecast.outputs.db_url
      target = ["production", "preview"]
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
      value  = data.onepassword_item.github_client_secret.password
      target = ["production"]
    },
    {
      key    = "AUTH_RESEND_KEY"
      value  = data.onepassword_item.resend_key.password
      target = ["production", "preview"]
    },
    {
      key    = "ANTHROPIC_API_KEY"
      value  = data.onepassword_item.anthropic_api_key.password
      target = ["production", "preview"]
    },
    {
      key    = "EMAIL_FROM"
      value  = var.hub_email_from
      target = ["production", "preview"]
    },
    {
      key    = "NEXTAUTH_SECRET"
      value  = random_password.hub_nextauth_secret.result
      target = ["production", "preview"]
    },
    {
      key    = "ENABLE_EXPERIMENTAL_COREPACK"
      value  = "1"
      target = ["production", "preview"]
    },
  ]

  # Hub depends on VERCEL_URL; see also: https://vercel.com/docs/security/deployment-protection#migrating-to-standard-protection
  vercel_authentication = {
    deployment_type = "only_preview_deployments"
  }

  # close to QURI database on DigitalOcean
  serverless_function_region = "iad1"
}

module "squiggle_hub_domain" {
  source = "../../modules/vercel-domain"

  domain     = local.squiggle_hub_domain
  project_id = vercel_project.hub.id
  www        = false
}

module "squiggle_hub_alternative_domains" {
  source = "../../modules/vercel-domain"

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
resource "digitalocean_record" "hub-sendgrid" {
  for_each = {
    "url1940" : "sendgrid.net.",
    "34091428" : "sendgrid.net.",
    "em6594" : "u34091428.wl179.sendgrid.net.",
    "s1._domainkey" : "s1.domainkey.u34091428.wl179.sendgrid.net.",
    "s2._domainkey" : "s2.domainkey.u34091428.wl179.sendgrid.net.",
  }

  domain = local.squiggle_hub_domain
  name   = each.key
  type   = "CNAME"
  ttl    = 300
  value  = each.value
}

# Resend DNS configuration; obtained from https://resend.com/domains
resource "digitalocean_record" "hub_resend" {
  for_each = {
    "mx" : {
      type  = "MX"
      name  = "send"
      value = "feedback-smtp.us-east-1.amazonses.com."
    },
    "spf" : {
      type  = "TXT"
      name  = "send"
      value = "v=spf1 include:amazonses.com ~all"
    },
    "dkim" : {
      type  = "TXT"
      name  = "resend._domainkey"
      value = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJbEJgQ3nN8wmt3R7yfuUxXXTCv+4DPXnu8fSOUXM/kQdfJrHGBxa4pgSwFUt6fCColcNDFtwrLIgNymz3Ye13V4y79SypQ4qV6gKfSFFj86NbK6znw10POSPHmHhoREVMooikIfYpFMPSfVkFGiZLgHeUBKj5gMsPXIW9Ri6FDwIDAQAB"
    }
  }

  domain   = local.squiggle_hub_domain
  name     = each.value.name
  type     = each.value.type
  ttl      = 300
  priority = each.value.type == "MX" ? 10 : null
  value    = each.value.value
}

resource "digitalocean_record" "hub_google_verification" {
  for_each = {
    # Which one is correct?
    "1" : "google-site-verification=Hsd2Gnz5SHJyJYyZMbdZDXzDnYovWfwiF2cWnIBH0C0",
    "2" : "google-site-verification=msJjgrChhh6V0p1pp0c0kj4Q_RdPEWrJk4yhRcN4uE4"
  }

  domain = local.squiggle_hub_domain
  name   = "@"
  type   = "TXT"
  ttl    = 300
  value  = each.value
}
