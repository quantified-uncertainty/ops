resource "vercel_project" "squiggle-components" {
  name = "squiggle-components"
  # No root_directory - it interferes with deploying with Github Actions.

  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project_domain" "squiggle-components" {
  domain     = "components.squiggle-language.com"
  project_id = vercel_project.squiggle-components.id
}

resource "vercel_project_domain" "squiggle-components-preview" {
  domain               = "preview-components.squiggle-language.com"
  redirect             = "components.squiggle-language.com"
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-components.id
  depends_on           = [vercel_project_domain.squiggle-components]
}

resource "vercel_project" "quri-ui" {
  name           = "quri-ui"
  root_directory = "packages/ui"

  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project" "squiggle-stories" {
  name      = "squiggle-stories"
  framework = "nextjs"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle-stories"
    type              = "github"
  }
}

resource "vercel_project" "guesstimate-app" {
  name      = "guesstimate-app"
  framework = "nextjs"

  git_repository = {
    production_branch = "nextjs"
    repo              = "berekuk/guesstimate-app"
    type              = "github"
  }
}

resource "vercel_project" "squiggle-tweaker" {
  name      = "squiggle-tweaker"
  framework = "nextjs"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle-tweaker"
    type              = "github"
  }
}
