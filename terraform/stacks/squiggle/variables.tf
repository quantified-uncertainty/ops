# used for GitHub SSO on Squiggle Hub
variable "github_client_id" {
  type    = string
  default = "e5e420b981eea10688c0"
}

# used for email notifications from Squiggle Hub
variable "hub_email_from" {
  type    = string
  default = "robot@squigglehub.org"
}

# Users with admin permissions on Squiggle Hub
variable "hub_root_emails" {
  type    = string
  default = "me@berekuk.ru,ozzieagooen@gmail.com"
}
