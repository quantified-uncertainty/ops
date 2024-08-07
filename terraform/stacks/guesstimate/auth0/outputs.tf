output "client_id" {
  value = auth0_client.frontend.client_id
}

output "client_secret" {
  value     = auth0_client_credentials.frontend.client_secret
  sensitive = true
}

output "backend_audience" {
  value = length(auth0_resource_server.backend) == 1 ? auth0_resource_server.backend[0].identifier : null
}

output "authentor_client_id" {
  value = auth0_client.authentor.client_id
}

output "authentor_client_secret" {
  value     = auth0_client_credentials.authentor.client_secret
  sensitive = true
}
