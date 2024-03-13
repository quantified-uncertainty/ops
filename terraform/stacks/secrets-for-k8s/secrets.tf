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

// Secret for "Sign in with GitHub" feature
data "onepassword_item" "argocd_github_oauth" {
  vault = data.onepassword_vault.main.uuid
  title = "GitHub Argo CD Client Secret"
}

# This secret is used by Argo CD configuration to authenticate with GitHub.
resource "kubernetes_secret" "dex_auth" {
  metadata {
    name      = "dex-github-auth" # must be in sync with `k8s/apps/argocd/config.yaml`
    namespace = "argocd"
  }

  data = {
    clientID     = data.onepassword_item.argocd_github_oauth.username
    clientSecret = data.onepassword_item.argocd_github_oauth.password
  }
}
