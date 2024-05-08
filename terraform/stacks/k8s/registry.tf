locals {
  # Should include the list of all namespaces that need to use the registry.
  # Sorry; this might be inconvenient, we'll have to figure out a better solution in the future.
  # Maybe we could copy the secret with Argo Workflows?
  registry_namespaces = toset([
    "guesstimate"
  ])

  # We use a single user for our container registry, with full permissions.
  # This is still an improvement over a default DigitalOcean Registry, which uses a token with full permissions for entire DO team.
  registry_user = "quri"
}

# We're using the DigitalOcean Container Registry to store our Docker images.
# So the registry is configured here and not through Argo CD.

resource "digitalocean_container_registry" "main" {
  # This name is also used by DO for k8s secret, which is awkward, but it's too late to rename.
  name                   = "quri"
  subscription_tier_slug = "basic"
}

# Separate credentials for jobs that need to push images
resource "digitalocean_container_registry_docker_credentials" "write" {
  registry_name = digitalocean_container_registry.main.name
  write         = true
}

# Credentials for workloads that need to _push_ images to the registry, i.e. CI workflows.
# Will usually be mounted to `/kaniko/.docker`.
resource "kubernetes_secret" "quri_registry_rw_credentials" {
  for_each = toset([var.ci_namespace])

  metadata {
    name      = "quri-registry-write"
    namespace = each.key
  }

  data = {
    "config.json" = digitalocean_container_registry_docker_credentials.write.docker_credentials
  }
}

resource "random_password" "registry_password" {
  length = 30
}

resource "kubernetes_secret" "registry_htpasswd" {
  metadata {
    name      = "quri-registry-htpasswd" # should match the name used by registry Helm chart (see in k8s/apps)
    namespace = "registry"
  }

  data = {
    "htpasswd" = <<EOF
${local.registry_user}:${random_password.registry_password.bcrypt_hash}
EOF
  }
}

resource "kubernetes_secret" "docker_config" {
  for_each = local.registry_namespaces

  metadata {
    name      = "dockerconfig"
    namespace = each.key
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "registry.registry" = {
          auth = base64encode("${local.registry_user}:${random_password.registry_password.result}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "github_actions_secret" "registry_password" {
  repository      = "GUCEM"
  secret_name     = "REGISTRY_PASSWORD"
  plaintext_value = random_password.registry_password.result
}
