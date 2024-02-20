locals {
  metaforecast_domain = "metaforecast.org"
}
resource "digitalocean_project" "metaforecast" {
  name        = "metaforecast.org"
  description = "Metaforecast.org resources."
}

resource "vercel_project" "metaforecast" {
  name      = "metaforecast"
  framework = "nextjs"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/metaforecast"
    type              = "github"
  }
}

module "metaforecast_domain" {
  source = "./vercel-domain"

  domain     = local.metaforecast_domain
  project_id = vercel_project.metaforecast.id
  www        = false
}

resource "digitalocean_project_resources" "metaforecast_resources" {
  project   = digitalocean_project.metaforecast.id
  resources = module.metaforecast_domain.digitalocean_urns
}
