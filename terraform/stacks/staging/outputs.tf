output "cluster_id" {
  description = "Staging Kubernetes cluster ID"
  value       = digitalocean_kubernetes_cluster.staging.id
}

output "cluster_endpoint" {
  description = "Staging Kubernetes cluster endpoint"
  value       = digitalocean_kubernetes_cluster.staging.endpoint
}

output "database_host" {
  description = "Staging database host"
  value       = digitalocean_database_cluster.staging.host
  sensitive   = true
}

output "database_connection_pool" {
  description = "Staging database connection pool URL"
  value       = module.staging_db.bouncer_url
  sensitive   = true
}

output "project_id" {
  description = "Staging DigitalOcean project ID"
  value       = digitalocean_project.staging.id
}
