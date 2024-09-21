# Provider secrets

# Vercel Team ID
# Get here: https://vercel.com/quantified-uncertainty/~/settings
# (not that secret, but still not stored in repo, just in case)
data "onepassword_item" "vercel_team_id" {
  vault = module.providers.op_vault
  title = "Vercel Team ID"
}

# Secret for "sign in with github" feature
data "onepassword_item" "github_client_secret" {
  vault = module.providers.op_vault
  title = "GitHub client secret"
}

# Used for Squiggle Hub. TODO: rename?
data "onepassword_item" "sendgrid_key" {
  vault = module.providers.op_vault
  title = "SendGrid key"
}

# Token for controlling GitHub, e.g. configuring action secrets in Squiggle repo.
# Get here: https://github.com/settings/tokens?type=beta (choose QURI org)
data "onepassword_item" "github_token" {
  vault = module.providers.op_vault
  title = "GitHub token"
}

// Token for uploading extensions to VS Code marketplace.
// Get here: https://code.visualstudio.com/api/working-with-extensions/publishing-extension#get-a-personal-access-token
data "onepassword_item" "vsce_pat" {
  vault = module.providers.op_vault
  title = "VSCode marketplace PAT token"
}

// Anthropic API key for Squiggle Hub AI generation.
data "onepassword_item" "anthropic_api_key" {
  vault = module.providers.op_vault
  title = "Anthropic API key"
}
