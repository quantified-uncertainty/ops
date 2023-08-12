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

resource "random_password" "quri_db_role" {
  for_each = var.quri_databases
  length   = 16
  special  = false # to avoid trouble with https://www.prisma.io/docs/reference/database-reference/connection-urls#special-characters
}

resource "postgresql_role" "quri_db_role" {
  provider = postgresql.quri
  for_each = var.quri_databases
  name     = each.value.role
  login    = true
  password = random_password.quri_db_role[each.key].result
}

# owned by `doadmin`
resource "postgresql_database" "quri_db" {
  for_each = {
    for k, v in var.quri_databases :
    k => v if v.create == true
  }
  provider = postgresql.quri
  name     = each.value.database
}

resource "postgresql_grant" "db_access" {
  provider    = postgresql.quri
  for_each    = var.quri_databases
  role        = each.value.role
  database    = each.value.database
  object_type = "database"
  privileges  = ["CREATE", "CONNECT", "TEMPORARY"]
  depends_on  = [postgresql_database.quri_db]
}

resource "postgresql_grant" "table_access" {
  provider    = postgresql.quri
  for_each    = var.quri_databases
  role        = each.value.role
  database    = each.value.database
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
  depends_on  = [postgresql_database.quri_db]
}

# Tighten permissions; default since PostgreSQL 15.
# https://www.depesz.com/2021/09/10/waiting-for-postgresql-15-revoke-public-create-from-public-schema-now-owned-by-pg_database_owner/
# Revoking from `public` schema didn't work for some reason, but revoking on database level did.
resource "postgresql_grant" "revoke_public" {
  provider    = postgresql.quri
  for_each    = var.quri_databases
  database    = each.value.database
  role        = "public"
  schema      = "public"
  object_type = "database"
  privileges  = []
  depends_on  = [postgresql_database.quri_db]
}

# Each DB gets its own connection pool.
resource "digitalocean_database_connection_pool" "per_db" {
  for_each   = var.quri_databases
  cluster_id = digitalocean_database_cluster.quri.id
  name       = each.key
  mode       = "transaction"
  size       = each.value.pool_size
  db_name    = each.value.database
  user       = each.value.role
  depends_on = [postgresql_database.quri_db]
}

locals {
  database_urls = {
    for k, v in var.quri_databases :
    k => {
      # Direct URLs are used for prisma migrations.
      # In general, `prisma migrate` might require `CREATEDB` permission, but `prisma migrate deploy` shouldn't require it, so it should be fine that the role doesn't have it.
      direct_url = "postgresql://${v.role}:${postgresql_role.quri_db_role[k].password}@${digitalocean_database_cluster.quri.host}:${digitalocean_database_cluster.quri.port}/${v.database}?sslmode=require"
      # `digitalocean_database_connection_pool.prod.uri` won't work because the user is created via Terraform and DigitalOcean doesn't expose the password in such URIs.
      bouncer_url = "postgresql://${v.role}:${postgresql_role.quri_db_role[k].password}@${digitalocean_database_connection_pool.per_db[k].host}:${digitalocean_database_connection_pool.per_db[k].port}/${digitalocean_database_connection_pool.per_db[k].name}?sslmode=require"
    }
  }
}
