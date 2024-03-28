output "db_uri" {
  value     = digitalocean_database_cluster.main.uri
  sensitive = true
}
