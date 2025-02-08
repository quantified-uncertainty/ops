variable "github_client_id" {
  type    = string
  default = "e5e420b981eea10688c0"
}

variable "hub_email_from" {
  type    = string
  default = "robot@squigglehub.org"
}

variable "hub_root_emails" {
  type    = string
  default = "me@berekuk.ru,ozzieagooen@gmail.com"
}

# copy-pasted from stacks/k8s/variables.tf
variable "github_app_quri" {
  default = {
    app_id          = 856482
    # installation_id = 48463969
  }
}
