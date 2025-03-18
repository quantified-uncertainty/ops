# We're self-hosting the Harbor (https://goharbor.io/) in Kubernetes.
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
#
# We've also tried the basic Docker registry (CNCF Distribution), but it didn't have garbage collection or Web UI.

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
# This password is used for the Harbor robot account for pulling images from the registry (see below).
resource "random_password" "registry_password" {
  length = 30
}

resource "harbor_robot_account" "dockerconfig" {
  name        = "for-dockerconfig"
  description = "Used by kubernetes to pull images from the registry"
  level       = "system"

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

resource "random_password" "registry_upload_password" {
  length = 30
}

# Account for uploading images to the Harbor registry from GitHub Actions.
resource "harbor_robot_account" "upload" {
  name        = "for-upload"
  description = "Used by GitHub Actions to push images to the registry"
  level       = "system"

  # same password as the one we used for old docker registry admin user
  secret = random_password.registry_upload_password.result
  permissions {
    access {
      action   = "pull"
      resource = "repository"
    }
    access {
      action   = "push"
      resource = "repository"
    }
    access {
      action   = "create"
      resource = "artifact-label"
    }
    access {
      action   = "create"
      resource = "tag"
    }
    kind      = "project"
    namespace = "*"
  }
}

# ================================ Harbor project ================================

resource "harbor_project" "main" {
  name   = "main"
  public = false
}


resource "harbor_retention_policy" "main" {
  scope    = harbor_project.main.id
  schedule = "Daily"

  # retain the last 3 images for the main (or master) branch
  rule {
    most_recently_pulled = 3
    repo_matching        = "**"
    tag_matching         = "{main,master}"
  }

  # retain the last 3 images for any tag, in case we forgot to tag images with branch name
  rule {
    most_recently_pulled = 3
    repo_matching        = "**"
    tag_matching         = "**"
  }

  # retain the last 5 images for all other branches, in case we do builds for pull requests
  rule {
    n_days_since_last_pull = 7
    repo_matching          = "**"
    tag_excluding          = "{main,master}"
  }
}

# ================================ Kubernetes secrets ================================

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
        // new registry - harbor
        "harbor.k8s.quantifieduncertainty.org" = {
          auth = base64encode("${harbor_robot_account.dockerconfig.full_name}:${random_password.registry_password.result}")
        },
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

# ================================ Github secrets ================================

# Export registry password to all GitHub repos that need it.
# GitHub Actions workflows can read it from the secret, and push images to the registry.
resource "github_actions_secret" "harbor_registry_password" {
  for_each = local.github_repositories

  repository      = each.key
  secret_name     = "HARBOR_REGISTRY_PASSWORD"
  plaintext_value = random_password.registry_upload_password.result
}

resource "github_actions_secret" "harbor_registry_password_getguesstimate" {
  provider = github.github-getguesstimate

  repository      = "guesstimate-server"
  secret_name     = "HARBOR_REGISTRY_PASSWORD"
  plaintext_value = random_password.registry_upload_password.result
}
