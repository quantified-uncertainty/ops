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

// Secret for "sign in with github" feature
data "onepassword_item" "github_client_secret" {
  vault = data.onepassword_vault.main.uuid
  title = "GitHub client secret"
}

# This secret is used by Argo CD configuration to authenticate with GitHub.
# Since Argo CD bundles Dex, it might also be used by other SSO integrations in the future.
# In other words, this is _very important_.
resource "kubernetes_secret" "dex_auth" {
  metadata {
    name      = "dex-github-auth" # must be in sync with `k8s/apps/argocd/config.yaml`
    namespace = "argocd"
  }

  data = {
    # Sorry for inlining; this could be loaded from a shared data-only module.
    # Note that this is also used in `quri` terraform stack, for configuring Squiggle Hub.
    clientID     = "e5e420b981eea10688c0"
    clientSecret = data.onepassword_item.github_client_secret.password
  }
}
