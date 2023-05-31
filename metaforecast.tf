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
