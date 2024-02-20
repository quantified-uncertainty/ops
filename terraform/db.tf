resource "digitalocean_project" "quri" {
  name        = "QURI"
  is_default  = true
  description = "Main project with QURI resources."
}

resource "digitalocean_database_cluster" "quri" {
  name       = "quri"
  engine     = "pg"
  version    = "14"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
  project_id = digitalocean_project.quri.id

  lifecycle {
    prevent_destroy = true
  }
}

provider "postgresql" {
  alias     = "quri"
  host      = digitalocean_database_cluster.quri.host
  database  = digitalocean_database_cluster.quri.database
  username  = digitalocean_database_cluster.quri.user
  password  = digitalocean_database_cluster.quri.password
  port      = digitalocean_database_cluster.quri.port
  superuser = false
}

module "prod_db" {
  source = "./database"

  providers = {
    postgresql = postgresql.quri
  }

  cluster   = digitalocean_database_cluster.quri
  name      = "prod"
  database  = "defaultdb"
  role      = "quri_prod_role"
  pool_size = 5
  create    = false # already exists
}

module "dev_db" {
  source = "./database"

  providers = {
    postgresql = postgresql.quri
  }

  cluster   = digitalocean_database_cluster.quri
  name      = "dev"
  database  = "quri_dev"
  role      = "quri_dev_role"
  pool_size = 3
  create    = true
}

module "guesstimate_db" {
  source = "./database"

  providers = {
    postgresql = postgresql.quri
  }

  cluster   = digitalocean_database_cluster.quri
  name      = "guesstimate"
  database  = "guesstimate"
  role      = "guesstimate_role"
  pool_size = 5
  create    = true
}
