resource "vercel_project" "squiggle-components" {
  name           = "squiggle-components"
  root_directory = "packages/components"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project" "quri-ui" {
  name           = "quri-ui"
  root_directory = "packages/ui"

  git_repository = {
    production_branch = "master"
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
