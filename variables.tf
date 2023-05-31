// secrets
variable "do_token" {
  type      = string
  sensitive = true
}

variable "vercel_api_token" {
  type      = string
  sensitive = true
}

variable "github_client_secret" {
  type      = string
  sensitive = true
}

variable "sendgrid_key" {
  type      = string
  sensitive = true
}

variable "hub_nextauth_secret" {
  type      = string
  sensitive = true
}

// public, defined in main.auto.tfvars
variable "github_client_id" {
  type = string
}

variable "hub_email_from" {
  type = string
}
