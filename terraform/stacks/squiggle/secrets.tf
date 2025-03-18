# Secret for "sign in with github" feature
data "onepassword_item" "github_client_secret" {
  vault = module.providers.op_vault
  title = "GitHub client secret"
}


# Used for Squiggle Hub. TODO: rename?
data "onepassword_item" "resend_key" {
  vault = module.providers.op_vault
  title = "Resend key"
}

// Anthropic API key for Squiggle Hub AI generation.
data "onepassword_item" "anthropic_api_key" {
  vault = module.providers.op_vault
  title = "Anthropic API key"
}
