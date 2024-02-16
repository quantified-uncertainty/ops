resource "digitalocean_project" "guesstimate" {
  name        = "www.getguesstimate.com"
  description = "Guesstimate resources."
}

resource "digitalocean_app" "guesstimate-server" {
  spec {
    name   = "golang-sample"
    region = "nyc1"

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
