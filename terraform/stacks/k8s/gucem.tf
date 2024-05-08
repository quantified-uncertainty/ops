# Set up GitHub "Deploy key", so that Argo CD could check out the repo with the latest chart and deploy it as an application.
# See:
# - https://github.com/quantified-uncertainty/GUCEM/settings/keys
# - https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key#example-usage
# - https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories

resource "tls_private_key" "argo_key" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "gucem_deploy_key" {
  title      = "For Argo CD"
  repository = "GUCEM"
  key        = tls_private_key.argo_key.public_key_openssh
  read_only  = true
}

resource "kubernetes_secret" "gucem_argo_repository" {
  metadata {
    name      = "gucem-repo"
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = "git@github.com:quantified-uncertainty/GUCEM.git"
    sshPrivateKey = tls_private_key.argo_key.private_key_openssh
  }
}
