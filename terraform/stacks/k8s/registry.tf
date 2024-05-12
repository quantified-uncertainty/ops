# We're self-hosting the Docker Registry (CNCF Distribution, https://distribution.github.io/distribution/) in Kubernetes.
#
# Reasons why I was unhappy with GitHub registry:
# - I'm confused about their pricing model, I think private images would require an organization subscription, but it's unclear; I managed to upload private images, but unsure how reliable it is
# - I'd need a GitHub token in our Kubernetes cluster to run private images
# - the easiest option is a personal token but it would expire in a year
# - other options would require a substantial infra to re-issue a cluster through a custom GitHub app, etc., or a service user in GitHub
#
# Reasons why I was unhappy with DigitalOcean registry:
# - security! their "container registry access token" gives full admin permissions; so I'm not comfortable with storing it in github env (misconfiguration could lead to someone getting the full access to our DO with full permissions through a pull request)
# - also, pricing and scaling; their $20 plan for registry is for 100GB (while a volume is $10/100GB, and can be more fine-grained); I'm not even sure how to increase it above 100GB if we need it

locals {
  # Should include the list of all namespaces that need to use the registry.
  # Sorry; this might be inconvenient, we'll have to figure out a better solution in the future.
  # Maybe we could copy the secret with Argo Workflows?
  registry_namespaces = toset([
    "quri-ci",
    "guesstimate",
    "gucem",
    "squiggle"
  ])

  # We use a single user for our container registry, with full permissions.
  # This is still an improvement over a default DigitalOcean Registry, which uses a token with full permissions for entire DO team.
  registry_user = "quri"
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
        // public ingress endpoint
        "registry.k8s.quantifieduncertainty.org" = {
          auth = base64encode("${local.registry_user}:${random_password.registry_password.result}")
        },
        // registry.registry is a internal k8s alias: `registry` service in `registry` kubernetes namespace
        "registry.registry" = {
          auth = base64encode("${local.registry_user}:${random_password.registry_password.result}")
        },
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
