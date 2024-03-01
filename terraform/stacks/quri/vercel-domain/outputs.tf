output "domain" {
  value = digitalocean_domain.main.name
}

output "digitalocean_urns" {
  description = "Can be used to assign resources to a DigitalOcean project"
  value = [
    digitalocean_domain.main.urn
  ]
}
