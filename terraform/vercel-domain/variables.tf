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
