# Provider secrets

# Vercel Team ID
# Get here: https://vercel.com/quantified-uncertainty/~/settings
# (not that secret, but still not stored in repo, just in case)
data "onepassword_item" "vercel_team_id" {
  vault = module.providers.op_vault
  title = "Vercel Team ID"
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
