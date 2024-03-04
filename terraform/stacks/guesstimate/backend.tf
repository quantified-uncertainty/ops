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
      name = "api.getguesstimate.com"
      type = "PRIMARY"
      zone = "getguesstimate.com"
    }

    service {
      name               = "guesstimate-server"
      instance_count     = 1
      instance_size_slug = "professional-xs"

      git {
        repo_clone_url = "https://github.com/getguesstimate/guesstimate-server"
        branch         = "2024"
      }
    }

    # The following are mostly secrets
    env {
      key   = "ALGOLIA_API_KEY"
      value = data.onepassword_item.algolia_api_key.password
      type  = "SECRET"
    }
    env {
      key   = "AUTH0_API_DOMAIN"
      value = var.auth0_domain
    }
    env {
      key   = "AUTH0_AUDIENCE"
      value = module.auth0_prod.backend_audience
    }
    env {
      key   = "AUTH0_API_TOKEN"
      value = data.onepassword_item.auth0_api_token.password
      type  = "SECRET"
    }
    env {
      key   = "AUTH0_CONNECTION"
      value = var.auth0_connection_name
    }

    env {
      key   = "CHARGEBEE_API_KEY"
      value = data.onepassword_item.chargebee_api_key.password
    }

    env {
      key   = "DATABASE_URL"
      value = heroku_addon.db.config_var_values["DATABASE_URL"]
      type  = "SECRET"
    }

    env {
      key   = "SECRET_KEY_BASE"
      value = random_bytes.rails_secret.hex
      type  = "SECRET"
    }

    env {
      key   = "SENDGRID_PASSWORD"
      value = data.onepassword_item.sendgrid_key.password
      type  = "SECRET"
    }
    env {
      key   = "SENDGRID_USERNAME"
      value = "apikey"
    }

    env {
      key   = "URLBOX_API_KEY"
      value = data.onepassword_item.urlbox_api_key.password
    }
    env {
      key   = "URLBOX_SECRET"
      value = data.onepassword_item.urlbox_secret.password
      type  = "SECRET"
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
