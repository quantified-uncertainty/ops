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
  description = "If set to false, redirect will happen from www.domain.com to domain.com, instead of the default domain.com -> www.domain.com. If `redirect` is set, this var won't affect anything."
}

variable "subdomain" {
  type     = string
  default  = null
  nullable = true
}

variable "redirect" {
  type        = string
  default     = ""
  description = "If set, both www.domain.com and domain.com will redirect to the given target"
}

variable "create_domain" {
  type        = bool
  nullable    = true
  default     = null
  description = "If true (default when redirects are not enabled), the domain will be created. If false, the domain will be assumed to exist and only the records will be created."
}
