# We're self-hosting the Docker Registry (CNCF Distribution, https://distribution.github.io/distribution/) in Kubernetes.
#
# We could use GitHub registry or DigitalOcean registry, but I was unhappy with both.
#
# Reasons why I was unhappy with GitHub registry:
# - I'm confused about their pricing model, I think private images would require an organization subscription, but it's unclear; I managed to upload private images, but unsure how reliable it is
# - I'd need a GitHub token in our Kubernetes cluster to run private images
#   - the easiest option is a personal token but it would expire in a year
#   - other options would require a substantial infra to re-issue a cluster through a custom GitHub app, etc., or a service user in GitHub
#
# Reasons why I was unhappy with DigitalOcean registry:
# - security! their "container registry access token" gives full admin permissions; so I'm not comfortable with storing it in github env (misconfiguration could lead to someone getting the full access to our DO with full permissions through a pull request)
# - also, pricing and scaling; their $20 plan for registry is for 100GB (while a volume is $10/100GB, and can be more fine-grained); I'm not even sure how to increase it above 100GB if we need it

locals {
  # Only the namespaces in this list will be able to pull images from the registry.
  # Sorry; this might be inconvenient, we'll have to figure out a better solution in the future.
  # Maybe we could copy the secret with Argo Workflows?
  registry_namespaces = toset([
    "quri-ci",
    "guesstimate",
    "gucem",
    "squiggle",
    "metaforecast",
  ])

  # The repositories in this list will be able to push images to the registry.
  github_repositories = toset([
    "GUCEM",
    "squiggle"
  ])

  # We use a single user for our container registry, with full permissions.
  # This is still an improvement over a default DigitalOcean Registry, which uses a token with full permissions for entire DO team.
  registry_user = "quri"
}

# Generate a random password for the registry.
# You can use it on https://registry.k8s.quantifieduncertainty.org (with `quri` as the username).
# To obtain the password, run `terraform output registry_password`.
resource "random_password" "registry_password" {
  length = 30
}

# Generate a htpasswd file on kubernetes. This is used by the registry Helm chart.
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

resource "harbor_robot_account" "dockerconfig" {
  name        = "for-dockerconfig"
  description = "Used by kubernetes to pull images from the registry"
  level       = "system"

  # same password as the one we used for old docker registry admin user
  secret = random_password.registry_password.result
  permissions {
    access {
      action   = "pull"
      resource = "repository"
    }
    kind      = "project"
    namespace = "*"
  }
}

# Export registry password to Kubernetes.
# This is necessary for Kubernetes Deployments to pull images from the registry.
resource "kubernetes_secret" "docker_config" {
  for_each = local.registry_namespaces

  metadata {
    name      = "dockerconfig"
    namespace = each.key
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        // public ingress endpoint, old registry
        "registry.k8s.quantifieduncertainty.org" = {
          auth = base64encode("${local.registry_user}:${random_password.registry_password.result}")
        },
        // new registry - harbor
        "harbor.k8s.quantifieduncertainty.org" = {
          auth = base64encode("${harbor_robot_account.dockerconfig.full_name}:${random_password.registry_password.result}")
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

# Export registry password to all GitHub repos that need it.
# GitHub Actions workflows can read it from the secret, and push images to the registry.
resource "github_actions_secret" "registry_password" {
  for_each = local.github_repositories

  repository      = each.key
  secret_name     = "REGISTRY_PASSWORD"
  plaintext_value = random_password.registry_password.result
}
