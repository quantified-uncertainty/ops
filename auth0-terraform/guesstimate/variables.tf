variable "frontend_url" {
  type = string
}

variable "backend_url" {
  type = string
}

variable "application_name" {
  type    = string
  default = "Guesstimate"
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
