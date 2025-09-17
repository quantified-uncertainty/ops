# PostgreSQL database cluster
resource "digitalocean_database_cluster" "main" {
  name       = "roast-my-post"
  engine     = "pg"
  version    = "16"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
  storage_size_mib = 1024 * 30  # 30GB storage

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

  sslmode = "require"
  superuser = false  # DigitalOcean doesn't provide superuser access

  connect_timeout = 60
}

# Create database and user using the database module
module "database" {
  source = "../../modules/database"

  name     = local.db_name
  role     = local.db_user
  database = local.db_name
  cluster  = digitalocean_database_cluster.main
  
  # Pool size for production workload
  pool_size = 17
  
  # Create the database
  create = true
}

# Create staging database and user
module "staging_database" {
  source = "../../modules/database"

  providers = {
    postgresql = postgresql
  }

  name      = "roast_my_post_staging"
  cluster   = digitalocean_database_cluster.main
  database  = "roast_my_post_staging"
  role      = "roast_my_post_staging_role"
  pool_size = 2
  create    = true
}

# Associate database cluster with the project
resource "digitalocean_project_resources" "db" {
  project   = digitalocean_project.main.id
  resources = [digitalocean_database_cluster.main.urn]
}
