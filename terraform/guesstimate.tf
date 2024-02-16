resource "digitalocean_project" "guesstimate" {
  name        = "Guesstimate"
  description = "Guesstimate resources."

  resources = [digitalocean_app.guesstimate-server.urn]
}

resource "digitalocean_app" "guesstimate-server" {
  spec {
    name     = "guesstimate-server"
    region   = "nyc1"
    features = ["buildpack-stack=ubuntu-20"]

    service {
      name               = "guesstimate-server"
      instance_count     = 1
      instance_size_slug = "professional-xs"

      git {
        repo_clone_url = "https://github.com/getguesstimate/guesstimate-server"
        branch         = "master"
      }
    }
  }
}
