resource "vercel_project" "squiggle-website" {
  name           = "squiggle-website"
  root_directory = "packages/website"

  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project_domain" "squiggle-website" {
  domain     = "www.squiggle-language.com"
  project_id = vercel_project.squiggle-website.id
}

resource "vercel_project_domain" "squiggle-website-redirects" {
  for_each             = toset(["squiggle-language.com", "preview.squiggle-language.com"])
  domain               = each.key
  redirect             = vercel_project_domain.squiggle-website.domain
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-website.id
}

# resource "vercel_dns_record" "squiggle-website-old-playground" {
#   domain = "squiggle-language.com"
#   name   = "playground"
#   type   = "A"
#   value  = "104.198.14.52"
# }
