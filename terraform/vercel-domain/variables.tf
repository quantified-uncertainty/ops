variable "domain" {
  type        = string
  description = "Primary domain without www."
}

variable "vercel_ip" {
  type    = string
  default = "76.76.21.21"
}

variable "project_id" {
  type        = string
  description = "Vercel project id"
}

variable "ttl" {
  type    = number
  default = 600
}

variable "www" {
  type        = bool
  default     = true
  description = "If set to false, redirect will happen from www.domain.com to domain.com, instead of the default domain.com -> www.domain.com."
}

variable "redirect" {
  type    = string
  default = ""
}
