data "onepassword_item" "goodjudgmentopen_cookie" {
  vault = "Metaforecast"
  title = "Good Judgment Open cookie"
}

data "onepassword_item" "google_api_key" {
  vault = "Metaforecast"
  title = "Google API key"
}

data "onepassword_item" "hypermind_cookie" {
  vault = "Metaforecast"
  title = "Hypermind cookie"
}

data "onepassword_item" "infer_cookie" {
  vault = "Metaforecast"
  title = "Infer cookie"
}

data "onepassword_item" "secret_betfair_endpoint" {
  vault = "Metaforecast"
  title = "Secret Betfair endpoint"
}

data "onepassword_item" "imgur_bearer" {
  vault = "Metaforecast"
  title = "Imgur bearer"
}

# Reference to squiggle repo GitHub Production environment defined in stacks/quri/github.tf
data "github_repository_environment" "production" {
  environment = "Production"
  repository  = "squiggle"
}

# Add Metaforecast database URL as a GitHub Actions secret for migrations
resource "github_actions_environment_secret" "metaforecast_database_url_prod" {
  repository      = "squiggle"
  secret_name     = "METAFORECAST_DATABASE_URL"
  environment     = data.github_repository_environment.production.environment
  plaintext_value = module.metaforecast.db_url
}
