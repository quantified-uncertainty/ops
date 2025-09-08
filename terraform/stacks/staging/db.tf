# PostgreSQL database cluster for staging
resource "digitalocean_database_cluster" "staging" {
  name       = "staging"
  engine     = "pg"
  version    = "16"
  size       = "db-s-1vcpu-1gb"  # Smallest size for staging
  region     = "nyc1"
  node_count = 1
  storage_size_mib = 1024 * 10  # 10GB storage for staging

  lifecycle {
    prevent_destroy = false  # Allow destruction for staging
  }
}

# PostgreSQL provider configuration for staging
provider "postgresql" {
  alias    = "staging"
  scheme   = "postgres"
  host     = digitalocean_database_cluster.staging.host
  port     = digitalocean_database_cluster.staging.port
  username = digitalocean_database_cluster.staging.user
  password = digitalocean_database_cluster.staging.password
  database = digitalocean_database_cluster.staging.database

  sslmode = "require"
  superuser = false

  connect_timeout = 60
}

# Create staging database using the database module
module "staging_db" {
  source = "../../modules/database"

  providers = {
    postgresql = postgresql.staging
  }

  name     = local.db_name
  role     = local.db_user
  database = local.db_name
  cluster  = digitalocean_database_cluster.staging
  
  # Smaller pool size for staging
  pool_size = 5
  
  # Create the database
  create = true
}

