# TODO: this file duplicates Terraform configuration in metaforecast github repo!
# That configuration should be folded here somehow, maybe through the private
# module or git submodule, or just moved here.

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

  # Metaforecast depends on VERCEL_URL; see also: https://vercel.com/docs/security/deployment-protection#migrating-to-standard-protection
  vercel_authentication = {
      deployment_type = "only_preview_deployments"
  }
}

module "metaforecast_domain" {
  source = "../../modules/vercel-domain"

  domain     = local.metaforecast_domain
  project_id = vercel_project.metaforecast.id
  www        = false
}

resource "digitalocean_project_resources" "metaforecast_resources" {
  project   = digitalocean_project.metaforecast.id
  resources = module.metaforecast_domain.digitalocean_urns
}
