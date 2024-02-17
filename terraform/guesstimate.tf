resource "digitalocean_project" "guesstimate" {
  name        = "Guesstimate"
  description = "Guesstimate resources."

  resources = [digitalocean_app.guesstimate-server.urn]
}

# Not ready for usage, env is not configured yet
resource "digitalocean_app" "guesstimate-server" {
  spec {
    name     = "guesstimate-server"
    region   = "nyc1"
    features = ["buildpack-stack=ubuntu-18"]

    service {
      name               = "guesstimate-server"
      instance_count     = 1
      instance_size_slug = "professional-xs"

      git {
        repo_clone_url = "https://github.com/getguesstimate/guesstimate-server"
        branch         = "production"
      }
    }
    # database {
    #   name         = "db"
    #   cluster_name = digitalocean_database_cluster.quri.name
    # }
  }
}

resource "heroku_app" "guesstimate" {
  name   = "guesstimate"
  region = "us"

  organization {
    name = "quantified-uncertainty-researc"
  }

}
