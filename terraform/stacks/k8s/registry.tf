# We're using the DigitalOcean Container Registry to store our Docker images.
# So the registry is configured here and not through Argo CD.

resource "digitalocean_container_registry" "main" {
  name                   = "quri"
  subscription_tier_slug = "starter"
}

resource "digitalocean_container_registry_docker_credentials" "main" {
  registry_name = digitalocean_container_registry.main.name
}

resource "kubernetes_secret" "quri_registry_credentials" {
  for_each = toset([
    # Should include the list of all namespaces that need to use the registry.
    # Sorry; this might be inconvenient, we'll have to figure out a better solution in the future.
    "guesstimate-server"
  ])

  metadata {
    name = "quri-registry"
  }

  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.main.docker_credentials
  }

  type = "kubernetes.io/dockerconfigjson"
}
