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

resource "vercel_project_domain" "main" {
  domain     = var.www ? "www.${var.domain}" : var.domain
  project_id = var.project_id
}

resource "vercel_project_domain" "www_redirect" {
  domain               = var.www ? var.domain : "www.${var.domain}"
  redirect             = var.www ? "www.${var.domain}" : var.domain
  redirect_status_code = 308
  project_id           = var.project_id
}

moved {
  from = vercel_project_domain.redirect_to_www
  to   = vercel_project_domain.www_redirect
}
