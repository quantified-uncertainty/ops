// secrets
variable "do_token" {
  type      = string
  sensitive = true
}

variable "vercel_api_token" {
  type      = string
  sensitive = true
}

variable "vercel_org_id" {
  type = string
}

// secret for "sign in with github" feature
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

// token for controlling github, e.g. configuring action secrets in Squiggle repo
variable "github_token" {
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

variable "quri_databases" {
  type = map(object({
    database  = string
    role      = string
    pool_size = number
    create    = bool
  }))

  default = {
    prod = {
      database  = "defaultdb"
      role      = "quri_prod_role"
      pool_size = 5
      create    = false # already exists
    }
    dev = {
      database  = "quri_dev"
      role      = "quri_dev_role"
      pool_size = 3
      create    = true
    }
  }
}
