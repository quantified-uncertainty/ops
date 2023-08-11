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

resource "random_password" "quri_dev_password" {
  length  = 16
  special = false # to avoid trouble with https://www.prisma.io/docs/reference/database-reference/connection-urls#special-characters
}

resource "postgresql_role" "quri_dev" {
  provider = postgresql.quri
  name     = "quri_dev_role"
  login    = true
  password = random_password.quri_dev_password.result
}

resource "random_password" "quri_prod_password" {
  length  = 16
  special = false
}

resource "postgresql_role" "quri_prod" {
  provider = postgresql.quri
  name     = "quri_prod_role"
  login    = true
  password = random_password.quri_prod_password.result
}

# We store production data on `defaultdb` for legacy reasons, so `quri_prod` role needs grants to access `defaultdb`.
resource "postgresql_grant" "quri_prod" {
  provider    = postgresql.quri
  role        = postgresql_role.quri_prod.name
  database    = "defaultdb"
  object_type = "database"
  privileges  = ["CREATE", "CONNECT", "TEMPORARY"]
}

resource "postgresql_grant" "quri_prod_tables" {
  provider    = postgresql.quri
  role        = postgresql_role.quri_prod.name
  database    = "defaultdb"
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
}

# `quri_dev_role` owns `quri_dev` DB, so there's no need to configure grants
resource "postgresql_database" "quri_dev" {
  provider   = postgresql.quri
  name       = "quri_dev"
  owner      = postgresql_role.quri_dev.name
  depends_on = [postgresql_role.quri_dev]
}

# Tighten permissions on `public` schemas; default since PostgreSQL 15.
# https://www.depesz.com/2021/09/10/waiting-for-postgresql-15-revoke-public-create-from-public-schema-now-owned-by-pg_database_owner/
resource "postgresql_grant" "revoke_public" {
  provider = postgresql.quri
  for_each = toset([
    "defaultdb",
    "quri_dev"
  ])
  database    = each.key
  role        = "public"
  schema      = "public"
  object_type = "schema"
  privileges  = []
}

# Legacy production DB pool for `doadmin` user.
resource "digitalocean_database_connection_pool" "defaultdb" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "defaultdb"
  mode       = "transaction"
  size       = 8
  db_name    = "defaultdb"
  user       = "doadmin"
}

# New production DB pool.
resource "digitalocean_database_connection_pool" "prod" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "prod"
  mode       = "transaction"
  size       = 5
  db_name    = "defaultdb"
  user       = "doadmin"
}

# Dev DB pool.
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
  database_direct_url     = digitalocean_database_cluster.quri.uri
  database_dev_direct_url = "postgresql://${postgresql_role.quri_dev.name}:${postgresql_role.quri_dev.password}@${digitalocean_database_cluster.quri.host}:${digitalocean_database_cluster.quri.port}/${postgresql_database.quri_dev.name}?sslmode=require"

  database_bouncer_url = digitalocean_database_connection_pool.defaultdb.uri

  # `digitalocean_database_connection_pool.dev.uri` won't work because the user is created via Terraform and DigitalOcean doesn't expose the password in such URIs.
  database_dev_bouncer_url = "postgresql://${postgresql_role.quri_dev.name}:${postgresql_role.quri_dev.password}@${digitalocean_database_connection_pool.dev.host}:${digitalocean_database_connection_pool.dev.port}/${digitalocean_database_connection_pool.dev.name}?sslmode=require"

}
