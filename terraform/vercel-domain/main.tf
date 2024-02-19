terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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
}

resource "digitalocean_record" "subdomains" {
  domain = digitalocean_domain.main.id
  name   = "*"
  type   = "CNAME"
  value  = "cname.vercel-dns.com."
}

resource "vercel_project_domain" "main" {
  domain     = "www.${digitalocean_domain.main.id}"
  project_id = var.project_id
}

resource "vercel_project_domain" "redirect_to_www" {
  domain               = digitalocean_domain.main.id
  redirect             = "www.${digitalocean_domain.main.id}"
  redirect_status_code = 308
  project_id           = var.project_id
}
