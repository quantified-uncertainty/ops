variable "frontend_url" {
  type = string
}

variable "extra_frontend_urls" {
  type    = list(string)
  default = []
}

variable "api_audience" {
  type     = string
  nullable = true # can be null for the legacy prod configuration
}

variable "application_name" {
  type    = string
  default = "Guesstimate"
}

variable "connection_name" {
  description = "Auth0 connection name. For historical reasons, this is called Guesstimate-test for prod."
  type        = string
  nullable    = true # can be null for the smooth migration to 2024 configuration
}

variable "jwt_alg" {
  type    = string
  default = "RS256"
}

variable "oidc_conformant" {
  # for backward compatibility in old Guesstimate application, can be inlined later
  type    = bool
  default = true
}

variable "sso" {
  # for backward compatibility in old Guesstimate application, can be inlined later
  type    = bool
  default = true
}

variable "app_type" {
  # for backward compatibility in old Guesstimate application, can be inlined later
  type     = string
  default  = "regular_web"
  nullable = true
}
