# Secrets for oauth2-proxy.
# It's used to protect https://alerts.k8s.quantifieduncertainty.org/ with GitHub SSO, and possibly other domains in the future.

data "onepassword_item" "quri_integrations_github_app_oauth" {
  vault = module.providers.op_vault
  title = "QURI Integrations GitHub App - OAuth credentials"
}

resource "random_password" "oauth2_proxy_cookie_secret" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "oauth2_proxy_secret" {
  metadata {
    name      = "quri-oauth2-proxy"
    namespace = "prometheus"
  }

  data = {
    clientID     = data.onepassword_item.quri_integrations_github_app_oauth.username
    clientSecret = data.onepassword_item.quri_integrations_github_app_oauth.password
    cookieSecret = random_password.oauth2_proxy_cookie_secret.result
  }
}
