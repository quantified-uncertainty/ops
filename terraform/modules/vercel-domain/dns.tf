resource "digitalocean_domain" "main" {
  count = var.subdomain == null ? 1 : 0 # assume that it already exists if using a subdomain
  name  = var.domain
}

resource "digitalocean_record" "apex_a" {
  depends_on = [digitalocean_domain.main]

  domain = var.domain
  name   = coalesce(var.subdomain, "@")
  type   = "A"
  value  = var.vercel_ip
  ttl    = var.ttl
}

resource "digitalocean_record" "subdomains" {
  depends_on = [digitalocean_domain.main]

  count  = var.subdomain == null ? 1 : 0 # assume that it already exists if using a subdomain
  domain = var.domain
  name   = "*" # TODO - is this too much? Do we want to allow only www here?
  type   = "CNAME"
  value  = "cname.vercel-dns.com."
  ttl    = var.ttl
}
