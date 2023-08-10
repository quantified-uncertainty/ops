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

resource "random_password" "quri_dev_db" {
  length = 16
}

resource "postgresql_role" "quri_dev" {
  provider = postgresql.quri
  name     = "quri_dev_role"
  login    = true
  password = random_password.quri_dev_db.result
}

resource "postgresql_database" "quri_dev" {
  provider = postgresql.quri
  name     = "quri_dev"
  owner    = postgresql_role.quri_dev.name
}

resource "digitalocean_database_connection_pool" "main" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "main"
  mode       = "transaction"
  size       = 15
  db_name    = "defaultdb"
  user       = "doadmin"
}

resource "digitalocean_database_connection_pool" "dev" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "dev"
  mode       = "transaction"
  size       = 3
  db_name    = postgresql_database.quri_dev.name
  user       = postgresql_role.quri_dev.name
}

resource "github_actions_secret" "database_url" {
  // used by "prisma migrate" action
  repository      = "squiggle"
  secret_name     = "DATABASE_URL"
  plaintext_value = digitalocean_database_cluster.quri.uri
}
