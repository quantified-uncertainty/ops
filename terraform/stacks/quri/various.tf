resource "vercel_project" "squiggle-components" {
  name           = "squiggle-components"
  root_directory = "packages/components"

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

resource "vercel_project_domain" "squiggle-components" {
  domain     = "components.squiggle-language.com"
  project_id = vercel_project.squiggle-components.id
}

resource "vercel_project_domain" "squiggle-components-preview" {
  domain               = "preview-components.squiggle-language.com"
  redirect             = vercel_project_domain.squiggle-components.domain
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-components.id
}

resource "vercel_project" "quri-ui" {
  name           = "quri-ui"
  root_directory = "packages/ui"

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

resource "vercel_project" "squiggle-stories" {
  name      = "squiggle-stories"
  framework = "nextjs"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle-stories"
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
