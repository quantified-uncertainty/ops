# TODO - move to squiggle stack.
locals {
  squiggle_website_domain = "squiggle-language.com"
}

resource "vercel_project" "squiggle-website" {
  name           = "squiggle-website"
  root_directory = "apps/website"

  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }

  environment = [
    {
      key    = "ENABLE_EXPERIMENTAL_COREPACK"
      value  = "1"
      target = ["production", "preview"]
    },
  ]
}

module "squiggle_website_domain" {
  source = "../../modules/vercel-domain"

  domain     = local.squiggle_website_domain
  project_id = vercel_project.squiggle-website.id
}

module "squiggle_website_alternative_domains" {
  source = "../../modules/vercel-domain"

  for_each = toset([
    "squigglelang.com",
    "squiggle-lang.com",
    "squigglelang.org",
    "squigglelanguage.com",
  ])

  domain     = each.key
  redirect   = "www.${local.squiggle_website_domain}"
  project_id = vercel_project.squiggle-website.id
}

# preview.squiggle-language.com was used by Netlify deployment, pre-2023.
resource "vercel_project_domain" "squiggle_website_old_preview_redirect" {
  project_id = vercel_project.squiggle-website.id

  domain               = "preview.${local.squiggle_website_domain}"
  redirect             = "www.${local.squiggle_website_domain}"
  redirect_status_code = 308
}

# Redirect configuration lives in vercel/playground-redirect/vercel.json.
resource "vercel_project" "squiggle_playground_redirect" {
  name             = "squiggle-playground-redirect"
  output_directory = "."
}

resource "vercel_project_domain" "squiggle_playground_redirect" {
  project_id = vercel_project.squiggle_playground_redirect.id
  domain     = "playground.${local.squiggle_website_domain}"
}

# Adopt the redirect provisioned during the approved October 2026 migration.
import {
  to = vercel_project.squiggle_playground_redirect
  id = "team_rtBRiFLJJzdbwXiEcgYyJ6ji/prj_YtBtEAYQbsAgiiNm2dWESPHCGS7A"
}

import {
  to = vercel_project_domain.squiggle_playground_redirect
  id = "team_rtBRiFLJJzdbwXiEcgYyJ6ji/prj_YtBtEAYQbsAgiiNm2dWESPHCGS7A/playground.squiggle-language.com"
}

# Keep the existing Terraform address for the DNS record migrated from Netlify.
resource "digitalocean_record" "squiggle-website-old-playground" {
  depends_on = [module.squiggle_website_domain] # waits for domain to be created on DO
  domain     = local.squiggle_website_domain
  name       = "playground"
  type       = "A"
  value      = "76.76.21.21"
  ttl        = 600
}
