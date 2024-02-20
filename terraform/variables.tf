// Provider secrets

// Get here: https://cloud.digitalocean.com/account/api/tokens
variable "do_token" {
  type      = string
  sensitive = true
}

// Get here: https://vercel.com/account/tokens
variable "vercel_api_token" {
  type      = string
  sensitive = true
}

// Get here: https://vercel.com/quantified-uncertainty/~/settings
// (not that secret, but still not stored in repo, just in case)
variable "vercel_org_id" {
  type = string
}

// Get through `heroku authorizations:create` in CLI.
// Note: Heroku tokens are global!
variable "heroku_api_key" {
  type      = string
  sensitive = true
}

// secret for "sign in with github" feature
variable "github_client_secret" {
  type      = string
  sensitive = true
}

// Get on Sendgrid website
variable "sendgrid_key" {
  type      = string
  sensitive = true
}

// Random string; TODO - move to state.
variable "hub_nextauth_secret" {
  type      = string
  sensitive = true
}

// Token for controlling github, e.g. configuring action secrets in Squiggle repo.
// Get here: https://github.com/settings/tokens?type=beta (choose QURI org)
variable "github_token" {
  type      = string
  sensitive = true
}


// Get here: https://code.visualstudio.com/api/working-with-extensions/publishing-extension#get-a-personal-access-token
variable "vsce_pat" {
  type        = string
  description = "Token for uploading extensions to VS Code marketplace"
  sensitive   = true
}

// public, defined in main.auto.tfvars
variable "github_client_id" {
  type = string
}

variable "hub_email_from" {
  type = string
}

variable "hub_root_emails" {
  type = string
}
