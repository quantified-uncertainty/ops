locals {
  # Should include the list of all namespaces that need to use the registry.
  # Sorry; this might be inconvenient, we'll have to figure out a better solution in the future.
  registry_credentials_namespaces = toset([
    "guesstimate"
  ])

  registry_credentials_rw_namespaces = toset([
    "quri-ci"
  ])
}

# We're using the DigitalOcean Container Registry to store our Docker images.
# So the registry is configured here and not through Argo CD.

resource "digitalocean_container_registry" "main" {
  name                   = "quri"
  subscription_tier_slug = "basic"
}

resource "digitalocean_container_registry_docker_credentials" "main" {
  registry_name = digitalocean_container_registry.main.name
}

# Separate credentials for jobs that need to push images
resource "digitalocean_container_registry_docker_credentials" "write" {
  registry_name = digitalocean_container_registry.main.name
  write         = true
}

# Credentials for workloads that need to _pull_ images from the registry.
resource "kubernetes_secret" "quri_registry_credentials" {
  for_each = toset(local.registry_credentials_namespaces)

  metadata {
    name      = "quri-registry"
    namespace = each.key
  }

  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.main.docker_credentials
  }

  type = "kubernetes.io/dockerconfigjson"
}

# Credentials for workloads that need to _push_ images to the registry, i.e. CI workflows.
# Will usually be mounted to `/kaniko/.docker`.
resource "kubernetes_secret" "quri_registry_rw_credentials" {
  for_each = toset(local.registry_credentials_rw_namespaces)

  metadata {
    name      = "quri-registry-write"
    namespace = each.key
  }

  data = {
    "config.json" = digitalocean_container_registry_docker_credentials.write.docker_credentials
  }
}
