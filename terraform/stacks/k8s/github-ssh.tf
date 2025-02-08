# Set up GitHub "Deploy key", so that Argo CD could check out the repos with their latest charts and deploy it as an application.
# See:
# - https://github.com/quantified-uncertainty/GUCEM/settings/keys
# - https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key#example-usage
# - https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories

locals {
  repos = toset([
    "GUCEM",
    # public repo, but HTTPS is problematic because of https://github.com/argoproj/argo-cd/issues/16532
    "metaforecast",
    "squiggle",
  ])
}

resource "tls_private_key" "argo_key" {
  for_each  = local.repos
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "argocd" {
  for_each   = local.repos
  title      = "For Argo CD"
  repository = each.value
  key        = tls_private_key.argo_key[each.key].public_key_openssh
  read_only  = true
}

resource "kubernetes_secret" "github_repo" {
  for_each = local.repos
  metadata {
    name      = "${lower(each.value)}-repo"
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = "git@github.com:quantified-uncertainty/${each.value}.git"
    sshPrivateKey = tls_private_key.argo_key[each.key].private_key_openssh
  }
}
