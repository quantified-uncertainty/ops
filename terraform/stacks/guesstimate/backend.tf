locals {
  backend_env = {
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

resource "digitalocean_project" "main" {
  name        = "Guesstimate"
  description = "Guesstimate resources."

  resources = [digitalocean_app.backend.urn, digitalocean_domain.main.urn]
}

resource "random_bytes" "rails_secret" {
  length = 64
}

resource "digitalocean_app" "backend" {
  spec {
    name     = "guesstimate-server"
    region   = "nyc"
    features = ["buildpack-stack=ubuntu-18"] # can't use ubuntu-22 because of legacy Ruby/Rails stack

    domain {
      name = var.api_domain # assuming that this is api.getguesstimate.com, but extracted to var because we also need it in frontend.tf
      type = "PRIMARY"
      zone = "getguesstimate.com"
    }

    service {
      name               = "guesstimate-server"
      instance_count     = 1
      instance_size_slug = "professional-xs"

      git {
        repo_clone_url = "https://github.com/getguesstimate/guesstimate-server"
        branch         = "main"
      }
    }

    dynamic "env" {
      for_each = local.backend_env
      content {
        key   = env.key
        value = env.value
        # Not all env vars are strictly secret, but it's easier to mark them all as secret
        type = "SECRET"
      }
    }
  }
}

# # Not used yet - we're still using Heroku for Guesstimate prod
# module "db" {
#   source = "../../modules/database"

#   providers = {
#     postgresql = postgresql.quri
#   }

#   cluster   = digitalocean_database_cluster.quri
#   name      = "guesstimate"
#   database  = "guesstimate"
#   role      = "guesstimate_role"
#   pool_size = 5
#   create    = true
# }

resource "kubernetes_namespace" "main" {
  metadata {
    name = "guesstimate"
  }
}

resource "kubernetes_secret" "backend_env" {
  metadata {
    name      = "guesstimate-server"
    namespace = "guesstimate"
  }

  data = local.backend_env
}
