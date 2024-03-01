terraform {
  required_providers {
    postgresql   = { source = "cyrilgdn/postgresql" }
    digitalocean = { source = "digitalocean/digitalocean" }
  }
}

resource "random_password" "password" {
  length  = 16
  special = false # to avoid trouble with https://www.prisma.io/docs/reference/database-reference/connection-urls#special-characters
}

resource "postgresql_role" "role" {
  name     = var.role
  login    = true
  password = random_password.password.result
}

# owned by `doadmin`
resource "postgresql_database" "db" {
  count = var.create ? 1 : 0
  name  = var.database
}

resource "postgresql_grant" "db_access" {
  role        = var.role
  database    = var.database
  object_type = "database"
  privileges  = ["CREATE", "CONNECT", "TEMPORARY"]
  depends_on  = [postgresql_database.db]
}

resource "postgresql_grant" "table_access" {
  role        = var.role
  database    = var.database
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
  depends_on  = [postgresql_database.db]
}

resource "postgresql_default_privileges" "db_access" {
  role        = var.role
  database    = var.database
  owner       = "doadmin"
  object_type = "schema"
  privileges  = ["CREATE"]
  depends_on  = [postgresql_database.db]
}

resource "postgresql_default_privileges" "table_access" {
  role        = var.role
  database    = var.database
  owner       = "doadmin"
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
  depends_on  = [postgresql_database.db]
}

# Tighten permissions; default since PostgreSQL 15.
# https://www.depesz.com/2021/09/10/waiting-for-postgresql-15-revoke-public-create-from-public-schema-now-owned-by-pg_database_owner/
# Revoking from `public` schema didn't work for some reason, but revoking on database level did.
resource "postgresql_grant" "revoke_public" {
  database    = var.database
  role        = "public"
  schema      = "public"
  object_type = "database"
  privileges  = []
  depends_on  = [postgresql_database.db]
}

# Each DB gets its own connection pool.
resource "digitalocean_database_connection_pool" "pool" {
  cluster_id = var.cluster.id
  name       = var.name
  mode       = "transaction"
  size       = var.pool_size
  db_name    = var.database
  user       = var.role
  depends_on = [postgresql_database.db]
}
