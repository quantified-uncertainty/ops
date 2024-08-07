variable "frontend_url" {
  type = string
}

variable "extra_frontend_urls" {
  type    = list(string)
  default = []
}

variable "api_audience" {
  type = string
}

variable "application_name" {
  type    = string
  default = "Guesstimate"
}

variable "connection_name" {
  description = "Auth0 connection name. For historical reasons, this is called Guesstimate-test for prod."
  type        = string
}

variable "jwt_alg" {
  type    = string
  default = "RS256"
}
