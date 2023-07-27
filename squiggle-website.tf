resource "vercel_project" "squiggle-website" {
  name           = "squiggle-website"
  root_directory = "packages/website"

  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project_domain" "squiggle-website-wwwless" {
  domain               = "squiggle-language.com"
  redirect             = "www.squiggle-language.com"
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-website.id
}

resource "vercel_project_domain" "squiggle-website-preview" {
  domain               = "preview.squiggle-language.com"
  redirect             = "www.squiggle-language.com"
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-website.id
}

resource "vercel_project_domain" "squiggle-website" {
  domain     = "www.squiggle-language.com"
  project_id = vercel_project.squiggle-website.id
}
