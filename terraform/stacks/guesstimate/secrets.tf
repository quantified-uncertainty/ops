# Urlbox (Screenshot SaaS) credentials for Guesstimate.
data "onepassword_item" "urlbox_api_key" {
  vault = module.providers.op_vault
  title = "Urlbox API key"
}
data "onepassword_item" "urlbox_secret" {
  vault = module.providers.op_vault
  title = "Urlbox API secret"
}

data "onepassword_item" "chargebee_api_key" {
  vault = module.providers.op_vault
  title = "Chargebee API key"
}

data "onepassword_item" "algolia_api_key" {
  vault = module.providers.op_vault
  title = "Algolia API key - Guesstimate"
}

# Used by Guesstimate backend.
data "onepassword_item" "sendgrid_key" {
  vault = module.providers.op_vault
  title = "SendGrid API key - Guesstimate"
}

# Used by Guesstimate backend to fetch users from Auth0 DB to our Postgres DB.
# TODO: this could've been created by Terraform, but no one remembers how this
# token was obtained.  Note that it has a special limited scope (you can see it
# by unpacking the token, e.g. with https://jwt.io/).
data "onepassword_item" "auth0_api_token" {
  vault = module.providers.op_vault
  title = "Auth0 API token / guesstimate users"
}
