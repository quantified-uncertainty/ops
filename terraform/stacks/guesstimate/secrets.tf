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
