resource "digitalocean_domain" "main" {
  name = "getguesstimate.com"
}

resource "digitalocean_record" "apex_a" {
  domain = digitalocean_domain.main.id
  name   = "@"
  type   = "A"
  value  = "104.198.14.52" # Netlify (legacy)
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.main.id
  name   = "www"
  type   = "CNAME"
  value  = "guesstimate.netlify.com."
}

resource "digitalocean_record" "star_a" {
  domain = digitalocean_domain.main.id
  name   = "*"
  type   = "A"
  value  = "75.126.100.17" # is this Netlify too?
}

# Sendgrid DNS configuration; copied from old name.com DNS
resource "digitalocean_record" "sendgrid" {
  for_each = {
    "default" : "u3141104.wl105.sendgrid.net.",
    "s1._domainkey" : "s1.domainkey.u3141104.wl105.sendgrid.net.",
    "s2._domainkey" : "s2.domainkey.u3141104.wl105.sendgrid.net.",
  }

  domain = digitalocean_domain.main.id
  name   = each.key
  type   = "CNAME"
  value  = each.value
}

resource "digitalocean_record" "mx" {
  for_each = {
    "alt1.aspmx.l.google.com." : 5,
    "alt2.aspmx.l.google.com." : 5,
    "alt3.aspmx.l.google.com." : 10,
    "alt4.aspmx.l.google.com." : 10,
    "aspmx.l.google.com." : 1,
  }

  domain   = digitalocean_domain.main.id
  name     = "@"
  type     = "MX"
  value    = each.key
  priority = each.value
}
