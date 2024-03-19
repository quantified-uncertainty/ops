resource "digitalocean_database_cluster" "main" {
  name       = "guesstimate"
  engine     = "pg"
  version    = "16"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
  storage_size_mib = 1024 * 20
  project_id = digitalocean_project.main.id

  lifecycle {
    prevent_destroy = true
  }
}
