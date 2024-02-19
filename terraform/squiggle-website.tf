locals {
  squiggle_website_domain = "squiggle-language.com"
}

resource "vercel_project" "squiggle-website" {
  name           = "squiggle-website"
  root_directory = "packages/website"

  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

module "squiggle_website_domain" {
  source = "./vercel-domain"

  domain     = local.squiggle_website_domain
  project_id = vercel_project.squiggle-website.id
}

module "squiggle_website_alternative_domains" {
  source = "./vercel-domain"

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

# Very old instance of Squiggle Playground, still hosted on Netlify.
# TODO: remove Netlify deployment and redirect to squiggle-language.com/playground (will require vercel.json config update)
resource "digitalocean_record" "squiggle-website-old-playground" {
  domain = module.squiggle_website_domain.domain # not from locals, waits for dependency
  name   = "playground"
  type   = "A"
  value  = "104.198.14.52"
}
