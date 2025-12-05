# Direct URLs are used for prisma migrations.
# Can't go through pool, migration fails with "must be owner of table" error.
output "direct_url" {
  value     = "postgresql://${var.cluster.user}:${var.cluster.password}@${var.cluster.host}:${var.cluster.port}/${var.database}?sslmode=require"
  sensitive = true
}

# `digitalocean_database_connection_pool.pool.uri` won't work because the user is created via Terraform and DigitalOcean doesn't expose the password in such URIs.
output "bouncer_url" {
  value     = "postgresql://${var.role}:${postgresql_role.role.password}@${digitalocean_database_connection_pool.pool.host}:${digitalocean_database_connection_pool.pool.port}/${digitalocean_database_connection_pool.pool.name}?sslmode=require"
  sensitive = true
}

output "ca_cert" {
  value     = data.digitalocean_database_ca.ca.certificate
  sensitive = true
}
