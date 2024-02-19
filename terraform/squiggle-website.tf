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

resource "vercel_project_domain" "squiggle_website_old_preview_redirect" {
  project_id = vercel_project.squiggle-website.id

  domain               = "preview.${local.squiggle_website_domain}"
  redirect             = "www.${local.squiggle_website_domain}"
  redirect_status_code = 308
}

resource "digitalocean_record" "squiggle-website-old-playground" {
  domain = squiggle_website_domain.domain # not from locals, waits for dependency
  name   = "playground"
  type   = "A"
  value  = "104.198.14.52"
}

locals {
  squiggle_website_domain = "squiggle-language.com"
}

// migration to module
moved {
  from = vercel_project_domain.squiggle-website
  to   = module.squiggle_website_domain.vercel_project_domain.main
}

moved {
  from = vercel_project_domain.squiggle-website-redirects["squiggle-language.com"]
  to   = module.squiggle_website_domain.vercel_project_domain.redirect_to_www
}

moved {
  from = vercel_project_domain.squiggle-website-redirects["preview.squiggle-language.com"]
  to   = vercel_project_domain.squiggle_website_old_preview_redirect
}
