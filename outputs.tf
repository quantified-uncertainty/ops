output "quri_db_uri" {
  value     = digitalocean_database_cluster.quri.uri
  sensitive = true
}
