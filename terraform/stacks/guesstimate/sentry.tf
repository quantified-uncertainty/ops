locals {
  sentry_organization = "quantified-uncertainty"
  sentry_team         = "quantified-uncertainty"
}

resource "sentry_project" "main" {
  organization = local.sentry_organization

  teams = [local.sentry_team]
  name  = "Guesstimate"
  slug  = "guesstimate-app"

  platform = "javascript-nextjs"
}

data "sentry_key" "main" {
  organization = local.sentry_organization
  project      = sentry_project.main.id

  first = true
}
