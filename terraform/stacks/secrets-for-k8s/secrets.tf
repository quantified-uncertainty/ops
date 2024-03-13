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

moved {
  from = kubernetes_secret.dex_auth
  to   = kubernetes_secret.argocd_github_auth
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
