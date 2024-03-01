output "client_id" {
  value = auth0_client.frontend.client_id
}

output "client_secret" {
  value     = auth0_client_credentials.frontend.client_secret
  sensitive = true
}

output "backend_audience" {
  value     = auth0_resource_server.backend.identifier
  sensitive = true
}
