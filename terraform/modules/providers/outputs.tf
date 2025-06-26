output "op_account" {
  value = "my.1password.com"
}

# Main 1Password vault
data "onepassword_vault" "main" {
  name = "Infra"
}

output "op_vault" {
  value = data.onepassword_vault.main.uuid
}

# DigitalOcean token
# Get here: https://cloud.digitalocean.com/account/api/tokens
data "onepassword_item" "do_token" {
  vault = data.onepassword_vault.main.uuid
  title = "DigitalOcean token"
}

output "do_token" {
  value     = data.onepassword_item.do_token.password
  sensitive = true
}

# Vercel API token
# Get here: https://vercel.com/account/tokens
data "onepassword_item" "vercel_api_token" {
  vault = data.onepassword_vault.main.uuid
  title = "Vercel API token"
}

output "vercel_api_token" {
  value     = data.onepassword_item.vercel_api_token.password
  sensitive = true
}

output "vercel_team" {
  value = "quantified-uncertainty"
}

output "vercel_team_id" {
  # From https://vercel.com/quantified-uncertainty/~/settings
  value = "team_rtBRiFLJJzdbwXiEcgYyJ6ji"
}

# Sentry token
data "onepassword_item" "sentry" {
  vault = data.onepassword_vault.main.uuid
  title = "Sentry root token"
}

output "sentry_token" {
  value = data.onepassword_item.sentry.password
}

# Heroku token.
# Get through `heroku authorizations:create` in CLI.
# Note: Heroku tokens are global!
data "onepassword_item" "heroku_api_key" {
  vault = data.onepassword_vault.main.uuid
  title = "Heroku API key"
}

output "heroku_api_key" {
  value = data.onepassword_item.heroku_api_key.password
}
