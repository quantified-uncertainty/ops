resource "digitalocean_domain" "main" {
  name = var.domain
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

# Obtain the IP of the Kubernetes load balancer.
data "kubernetes_service" "nginx_ingress_service" {
  metadata {
    namespace = "ingress-nginx"
    name = "ingress-nginx-controller"
  }
}

resource "digitalocean_record" "api" {
  domain = digitalocean_domain.main.id
  name   = "api"
  type   = "A"
  value  = data.kubernetes_service.nginx_ingress_service.status.0.load_balancer.0.ingress.0.ip
}
