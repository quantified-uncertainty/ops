resource "digitalocean_project" "main" {
  name        = "Guesstimate"
  description = "Guesstimate resources."

  resources = [digitalocean_domain.main.urn]
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = var.k8s_namespace
  }
}

resource "random_bytes" "rails_secret" {
  length = 64
}

resource "kubernetes_secret" "backend_env" {
  metadata {
    name      = var.k8s_backend_env_secret
    namespace = var.k8s_namespace
  }

  data = {
    "ALGOLIA_API_KEY"   = data.onepassword_item.algolia_api_key.password
    "AUTH0_API_DOMAIN"  = var.auth0_domain
    "AUTH0_AUDIENCE"    = module.auth0_prod.backend_audience
    "AUTH0_API_TOKEN"   = data.onepassword_item.auth0_api_token.password
    "AUTH0_CONNECTION"  = var.auth0_connection_name
    "CHARGEBEE_API_KEY" = data.onepassword_item.chargebee_api_key.password
    "DATABASE_URL"      = heroku_addon.db.config_var_values["DATABASE_URL"]
    "SECRET_KEY_BASE"   = random_bytes.rails_secret.hex
    "SENDGRID_PASSWORD" = data.onepassword_item.sendgrid_key.password
    "SENDGRID_USERNAME" = "apikey"
    "URLBOX_API_KEY"    = data.onepassword_item.urlbox_api_key.password
    "URLBOX_SECRET"     = data.onepassword_item.urlbox_secret.password
  }
}
