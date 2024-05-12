# OAuth secrets, for when we need to authorize a deployment with oauth2-proxy and GitHub SSO.

data "onepassword_item" "quri_integrations_github_app_oauth" {
  vault = module.providers.op_vault
  title = "QURI Integrations GitHub App - OAuth credentials"
}

resource "random_password" "oauth2_proxy_cookie_secret" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "oauth2_proxy_secret" {
  for_each = toset([
    "prometheus", # alerts.k8s.quantifieduncertainty.org
    "gucem"       # GUCEM
  ])
  metadata {
    name      = "quri-oauth2-proxy"
    namespace = each.key
  }

  data = {
    clientID     = data.onepassword_item.quri_integrations_github_app_oauth.username
    clientSecret = data.onepassword_item.quri_integrations_github_app_oauth.password
    cookieSecret = random_password.oauth2_proxy_cookie_secret.result
  }
}
