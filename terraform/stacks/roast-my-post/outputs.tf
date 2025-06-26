output "database_url" {
  value     = module.database.bouncer_url
  sensitive = true
}

output "database_url_prisma" {
  value     = module.database.direct_url
  sensitive = true
}

output "database_host" {
  value = digitalocean_database_cluster.main.host
}

output "database_port" {
  value = digitalocean_database_cluster.main.port
}

output "vercel_project_id" {
  value = vercel_project.main.id
}

output "domain" {
  value = local.domain
}

output "k8s_namespace" {
  value = local.k8s_namespace
}