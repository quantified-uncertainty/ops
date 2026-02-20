# PostgreSQL database cluster
resource "digitalocean_database_cluster" "main" {
  name             = "longtermwiki"
  engine           = "pg"
  version          = "16"
  size             = "db-s-1vcpu-1gb"
  region           = local.region
  node_count       = 1
  storage_size_mib = 1024 * 30 # 30GB storage

  lifecycle {
    prevent_destroy = true
  }
}

# PostgreSQL provider configuration
provider "postgresql" {
  scheme   = "postgres"
  host     = digitalocean_database_cluster.main.host
  port     = digitalocean_database_cluster.main.port
  username = digitalocean_database_cluster.main.user
  password = digitalocean_database_cluster.main.password
  database = digitalocean_database_cluster.main.database

  sslmode   = "require"
  superuser = false # DigitalOcean doesn't provide superuser access

  connect_timeout = 60
}

# Create database and user using the database module
module "database" {
  source = "../../modules/database"

  name     = local.db_name
  role     = local.db_user
  database = local.db_name
  cluster  = digitalocean_database_cluster.main

  pool_size = 10
  create    = true
}

# Associate database cluster with the project
resource "digitalocean_project_resources" "db" {
  project   = digitalocean_project.main.id
  resources = [digitalocean_database_cluster.main.urn]
}