output "digitalocean_urns" {
  description = "All urns that were created on DigitalOcean by this module. Can be used to assign resources to a DigitalOcean project."
  value       = [for domain in digitalocean_domain.main : domain.urn]
}
