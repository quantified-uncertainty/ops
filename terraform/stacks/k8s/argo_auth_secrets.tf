# These secrets have two layers:
# 1. Argo Workflows and Argo CD authenticate against Dex bundled with Argo CD using argo-workflows-sso secret.
# 2. Argo CD Dex authenticates against GitHub using dex-github-auth secret.

# See also: `patches/inject-workflows-sso-secret.yaml` and `dex.config` in `patches/config.yaml` in argocd app manifests.


# 1. This secret is used by Argo Workflows configuration to authenticate against Argo CD Dex.
# TODO: it should be possible to create it in Kubernetes instead of Terraform,
# since it doesn't rely on 1Password secrets. But Terraform's `random_password`
# is more reliable than Helm, so we create it here.

resource "random_password" "argo_workflows_auth_secret" {
  length = 32
}

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

# 2. This secret is used by Argo CD Dex to authenticate with GitHub.

data "onepassword_item" "argocd_github_oauth" {
  vault = module.providers.op_vault
  title = "GitHub Argo CD Client Secret"
}

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
