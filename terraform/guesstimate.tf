resource "digitalocean_project" "guesstimate" {
  name        = "Guesstimate"
  description = "Guesstimate resources."

  resources = [digitalocean_app.guesstimate-server.urn]
}

data "terraform_remote_state" "auth0" {
  backend = "s3"

  config = {
    region         = "us-east-1"
    bucket         = "quri-tf-state-us-east-1"
    key            = "auth0.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = "true"
  }
}

resource "random_bytes" "guesstimate_rails_secret" {
  length = 64
}

resource "digitalocean_app" "guesstimate-server" {
  spec {
    name     = "guesstimate-server"
    region   = "nyc"
    features = ["buildpack-stack=ubuntu-18"] # can't use ubuntu-22 because of legacy Ruby/Rails stack

    service {
      name               = "guesstimate-server"
      instance_count     = 1
      instance_size_slug = "professional-xs"

      git {
        repo_clone_url = "https://github.com/getguesstimate/guesstimate-server"
        branch         = "production"
      }
    }

    # The following are mostly secrets
    env {
      key   = "ALGOLIA_API_KEY"
      value = data.onepassword_item.algolia_api_key_guesstimate.password
      type  = "SECRET"
    }
    env {
      key   = "AUTH0_API_DOMAIN"
      value = data.terraform_remote_state.auth0.outputs.guesstimate_domain
    }
    env {
      key   = "AUTH0_AUDIENCE"
      value = data.terraform_remote_state.auth0.outputs.guesstimate_backend_audience
    }
    env {
      key   = "AUTH0_API_TOKEN"
      value = data.onepassword_item.guesstimate_auth0_api_token.password
      type  = "SECRET"
    }
    env {
      key   = "AUTH0_CLIENT_ID"
      value = data.terraform_remote_state.auth0.outputs.guesstimate_client_id
    }

    env {
      key   = "AUTH0_CLIENT_SECRET"
      value = data.terraform_remote_state.auth0.outputs.guesstimate_client_secret
    }
    env {
      key   = "AUTH0_CONNECTION"
      value = data.terraform_remote_state.auth0.outputs.guesstimate_connection_name
    }

    env {
      key   = "CHARGEBEE_API_KEY"
      value = data.onepassword_item.chargebee_api_key.password
    }

    env {
      key   = "DATABASE_URL"
      value = heroku_addon.guesstimate_db.config_var_values["DATABASE_URL"]
    }

    env {
      key   = "SECRET_KEY_BASE"
      value = random_bytes.guesstimate_rails_secret.hex
    }

    env {
      key   = "SENDGRID_PASSWORD"
      value = data.onepassword_item.sendgrid_key_guesstimate.password
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
    }
  }
}

resource "heroku_app" "guesstimate" {
  name   = "guesstimate"
  region = "us"

  organization {
    name = "quantified-uncertainty-researc"
  }
}

resource "heroku_addon" "guesstimate_db" {
  app_id = heroku_app.guesstimate.id
  plan   = "heroku-postgresql:standard-0"
}
