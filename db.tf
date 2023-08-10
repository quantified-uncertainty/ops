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
  provider   = postgresql.quri
  name       = "quri_dev"
  owner      = postgresql_role.quri_dev.name
  depends_on = [postgresql_role.quri_dev]
}

// Legacy, will be replaced by `defaultdb` pool.
resource "digitalocean_database_connection_pool" "main" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "main"
  mode       = "transaction"
  size       = 7
  db_name    = "defaultdb"
  user       = "doadmin"
}

// Production DB pool.
resource "digitalocean_database_connection_pool" "defaultdb" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "defaultdb"
  mode       = "transaction"
  size       = 8
  db_name    = "defaultdb"
  user       = "doadmin"
}

// Dev DB pool.
resource "digitalocean_database_connection_pool" "dev" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "dev"
  mode       = "transaction"
  size       = 3
  db_name    = postgresql_database.quri_dev.name
  user       = postgresql_role.quri_dev.name
  depends_on = [postgresql_database.quri_dev]
}

locals {
  // Could be done with `digitalocean_database_connection_pool.defaultdb.uri`, but we use longer version for parity with `database_dev_url`.
  database_bouncer_url = "postgresql://${digitalocean_database_connection_pool.defaultdb.user}:${digitalocean_database_connection_pool.defaultdb.password}@${digitalocean_database_connection_pool.defaultdb.host}:${digitalocean_database_connection_pool.defaultdb.port}/${digitalocean_database_connection_pool.defaultdb.name}?sslmode=require"

  // `digitalocean_database_connection_pool.dev.uri` won't work because the user is created via Terraform and DigitalOcean doesn't expose the password in such URIs.
  database_dev_bouncer_url = "postgresql://${digitalocean_database_connection_pool.dev.user}:${digitalocean_database_connection_pool.dev.password}@${digitalocean_database_connection_pool.dev.host}:${digitalocean_database_connection_pool.dev.port}/${digitalocean_database_connection_pool.dev.name}?sslmode=require"

}
resource "github_actions_secret" "database_url" {
  // Used by "prisma migrate" action.
  repository  = "squiggle"
  secret_name = "DATABASE_URL"
  // TODO: should be direct URL instead, https://www.prisma.io/docs/guides/performance-and-optimization/connection-management/configure-pg-bouncer#prisma-migrate-and-pgbouncer-workaround.
  plaintext_value = local.database_bouncer_url
}

resource "github_actions_secret" "database_dev_url" {
  repository      = "squiggle"
  secret_name     = "DATABASE_DEV_URL"
  plaintext_value = local.database_dev_bouncer_url
}
