resource "digitalocean_project" "main" {
  name        = "Guesstimate"
  description = "Guesstimate resources."

  resources = [digitalocean_domain.main.urn, digitalocean_database_cluster.main.urn]
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
    "ALGOLIA_API_KEY" = data.onepassword_item.algolia_api_key.password

    # Auth0 tenant domain
    "AUTH0_API_DOMAIN" = var.auth0_domain

    # Guesstimate API audience
    "AUTH0_AUDIENCE" = module.auth0_2024.backend_audience

    # Credentials for creating and reading users from auth0, used by authentor.rb in guesstimate-server
    "AUTH0_CLIENT_ID"     = module.auth0_2024.authentor_client_id
    "AUTH0_CLIENT_SECRET" = module.auth0_2024.authentor_client_secret

    # Name of the Auth0 users database
    "AUTH0_CONNECTION" = var.auth0_connection_name

    "CHARGEBEE_API_KEY" = data.onepassword_item.chargebee_api_key.password
    "DATABASE_URL"      = digitalocean_database_cluster.main.uri
    "SECRET_KEY_BASE"   = random_bytes.rails_secret.hex
    "SENDGRID_PASSWORD" = data.onepassword_item.sendgrid_key.password
    "SENDGRID_USERNAME" = "apikey"
    "URLBOX_API_KEY"    = data.onepassword_item.urlbox_api_key.password
    "URLBOX_SECRET"     = data.onepassword_item.urlbox_secret.password
  }
}
