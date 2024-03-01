// Provider secrets

// DigitalOcan token
// Get here: https://cloud.digitalocean.com/account/api/tokens
data "onepassword_item" "do_token" {
  vault = data.onepassword_vault.main.uuid
  title = "DigitalOcean token"
}

// Vercel API token
// Get here: https://vercel.com/account/tokens
data "onepassword_item" "vercel_api_token" {
  vault = data.onepassword_vault.main.uuid
  title = "Vercel API token"
}

// Vercel Team ID
// Get here: https://vercel.com/quantified-uncertainty/~/settings
// (not that secret, but still not stored in repo, just in case)
data "onepassword_item" "vercel_team_id" {
  vault = data.onepassword_vault.main.uuid
  title = "Vercel Team ID"
}

// Heroku API key
// Get through `heroku authorizations:create` in CLI.
// Note: Heroku tokens are global!
data "onepassword_item" "heroku_api_key" {
  vault = data.onepassword_vault.main.uuid
  title = "Heroku API key"
}

// Secret for "sign in with github" feature
data "onepassword_item" "github_client_secret" {
  vault = data.onepassword_vault.main.uuid
  title = "GitHub client secret"
}

// Used for Squiggle Hub. TODO: rename?
data "onepassword_item" "sendgrid_key" {
  vault = data.onepassword_vault.main.uuid
  title = "SendGrid key"
}

// Token for controlling GitHub, e.g. configuring action secrets in Squiggle repo.
// Get here: https://github.com/settings/tokens?type=beta (choose QURI org)
data "onepassword_item" "github_token" {
  vault = data.onepassword_vault.main.uuid
  title = "GitHub token"
}

// Token for uploading extensions to VS Code marketplace.
// Get here: https://code.visualstudio.com/api/working-with-extensions/publishing-extension#get-a-personal-access-token
data "onepassword_item" "vsce_pat" {
  vault = data.onepassword_vault.main.uuid
  title = "VSCode marketplace PAT token"
}

// Urlbox (Screenshot SaaS) credentials for Guesstimate.
data "onepassword_item" "urlbox_api_key" {
  vault = data.onepassword_vault.main.uuid
  title = "Urlbox API key"
}
data "onepassword_item" "urlbox_secret" {
  vault = data.onepassword_vault.main.uuid
  title = "Urlbox API secret"
}

data "onepassword_item" "chargebee_api_key" {
  vault = data.onepassword_vault.main.uuid
  title = "Chargebee API key"
}


data "onepassword_item" "algolia_api_key_guesstimate" {
  vault = data.onepassword_vault.main.uuid
  title = "Algolia API key - Guesstimate"
}


// Used by Guesstimate backend.
data "onepassword_item" "sendgrid_key_guesstimate" {
  vault = data.onepassword_vault.main.uuid
  title = "SendGrid API key - Guesstimate"
}

// Used by Guesstimate backend to fetch users from Auth0 DB to our Postgres DB.
// TODO: this could've been created by Terraform, but no one remembers how this
// token was obtained.  Note that it has a special limited scope (you can see it
// by unpacking the token, e.g. with https://jwt.io/).
data "onepassword_item" "guesstimate_auth0_api_token" {
  vault = data.onepassword_vault.main.uuid
  title = "Auth0 API token / guesstimate users"
}
