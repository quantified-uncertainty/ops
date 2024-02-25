variable "frontend_url" {
  type = string
}

variable "backend_url" {
  type = string
}

variable "suffix" {
  type        = string
  default     = ""
  description = "Will be appended to guesstimate-app and guesstimate-backend resource names. Useful for dev."
}
