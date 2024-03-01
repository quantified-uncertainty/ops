output "guesstimate_domain" {
  value = var.guesstimate_auth0_domain
}

output "guesstimate_management_api_token" {
  value = ""
}

output "guesstimate_client_id" {
  value = module.guesstimate_prod.client_id
}

output "guesstimate_client_secret" {
  value     = module.guesstimate_prod.client_secret
  sensitive = true
}

output "guesstimate_connection_name" {
  value = var.guesstimate_auth0_connection_name
}

output "guesstimate_backend_audience" {
  value     = module.guesstimate_prod.backend_audience
  sensitive = true # not really sensitive, but Terraform requires it
}
