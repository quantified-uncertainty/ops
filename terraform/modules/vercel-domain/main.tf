terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.4"
    }
  }
}

locals {
  apex_domain = var.domain

  primary_domain = var.redirect == "" ? (
    var.www ? "www.${var.domain}" : var.domain
  ) : var.redirect
}

resource "digitalocean_domain" "main" {
  name = var.domain
}

resource "digitalocean_record" "apex_a" {
  domain = digitalocean_domain.main.id
  name   = "@"
  type   = "A"
  value  = var.vercel_ip
  ttl    = var.ttl
}

resource "digitalocean_record" "subdomains" {
  domain = digitalocean_domain.main.id
  name   = "*"
  type   = "CNAME"
  value  = "cname.vercel-dns.com."
  ttl    = var.ttl
}

# Main can point to www.domain.com or to domain.com, depending on whether `www` flag is set.
# Note that if `redirect` is also set, this won't matter, because both domain.com and www.domain.com will point to the same external domain.
resource "vercel_project_domain" "main" {
  project_id = var.project_id

  domain = var.www ? "www.${var.domain}" : var.domain

  redirect             = var.redirect == "" ? null : local.primary_domain
  redirect_status_code = var.redirect == "" ? null : 308
}

resource "vercel_project_domain" "www_redirect" {
  project_id = var.project_id

  # Inverted compared to `main` domain
  domain = var.www ? var.domain : "www.${var.domain}"

  redirect             = local.primary_domain
  redirect_status_code = 308
}
