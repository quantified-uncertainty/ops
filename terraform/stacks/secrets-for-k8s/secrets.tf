resource "kubernetes_secret" "grafana" {
  metadata {
    name = "grafana-credentials" # must be in sync with `k8s/apps/prometheus/values.yaml`
    # This namespace should already exist. This might make the bootstrapping of the entire configuration awkward.
    # (we could create a namespace with Terraform if we ever need to reset the entire cluster, but that's not very probable)
    namespace = "prometheus" # must be in sync with `k8s/app-manifests/prometheus-stack.yaml`
  }

  data = {
    admin-user     = data.onepassword_item.grafana_admin.username
    admin-password = data.onepassword_item.grafana_admin.password
  }
}

data "onepassword_item" "argocd_github_oauth" {
  vault = data.onepassword_vault.main.uuid
  title = "GitHub Argo CD Client Secret"
}

data "onepassword_item" "quri_integrations_for_guesstimate_github_app" {
  vault = data.onepassword_vault.main.uuid
  title = "QURI Integrations GitHub App Private Key"
}

data "onepassword_item" "quri_integrations_github_app" {
  vault = data.onepassword_vault.main.uuid
  title = "QURI Integrations for Guesstimate GitHub App Private Key"
}

# This secret is used by Argo CD configuration to authenticate with GitHub.
resource "kubernetes_secret" "argocd_github_auth" {
  metadata {
    name      = "dex-github-auth" # must be in sync with `k8s/apps/argocd/config.yaml`
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    clientID     = data.onepassword_item.argocd_github_oauth.username
    clientSecret = data.onepassword_item.argocd_github_oauth.password
  }
}

resource "random_password" "argo_workflows_auth_secret" {
  length = 32
}

# This secret is used by Argo Workflows configuration to authenticate against Argo CD Dex.
# TODO: it should be possible to create it in Kubernetes instead of Terraform, since it doesn't rely on 1Password secrets.
resource "kubernetes_secret" "argo_workflows_github_auth" {
  for_each = toset([
    # https://argo-workflows.readthedocs.io/en/latest/argo-server-sso-argocd/:
    # "If Argo CD and Argo Workflows are installed in different namespaces the secret must be present in both of them."
    "argocd",
    "argo-workflows",
  ])

  metadata {
    name      = "argo-workflows-sso"
    namespace = each.key
  }

  data = {
    clientID     = "argo-workflows-sso"
    clientSecret = random_password.argo_workflows_auth_secret.result
  }
}

# This secret is used by Argo Workflows configuration to run GitHub Actions-like CI workflows.
# Our custom GitHub app uses these credentials to obtain a short-lived GITHUB_TOKEN, which is used to authenticate against GitHub API.
# Specifically, that token can be useful for:
# - uploading Docker images to GitHub registry
# - (TODO) posting comments to PRs
# - (TODO) updating checks in PRs
# Or anything else that's often done from GitHub Actions, but in our case it's done from Argo Workflows.
resource "kubernetes_secret" "argo_workflows_github_token_credentials" {
  metadata {
    name      = "quri-integrations-for-guesstimate-github-app"
    namespace = "guesstimate" # TODO - move to a common CI namespace?
  }

  data = {
    app-id                         = 856293   # TODO - could this be obtained from a data source?
    getguesstimate-installation-id = 48456163 # TODO - and this?
    private-key                    = data.onepassword_item.quri_integrations_github_app.note_value
  }
}

# TODO: same resource for quantified-uncertainty GitHub app
