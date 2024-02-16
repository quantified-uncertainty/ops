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



moved {
  from = postgresql_database.quri_db["dev"]
  to   = module.dev_db.postgresql_database.db[0]
}

moved {
  from = postgresql_default_privileges.db_access["dev"]
  to   = module.dev_db.postgresql_default_privileges.db_access
}

moved {
  from = postgresql_default_privileges.db_access["prod"]
  to   = module.prod_db.postgresql_default_privileges.db_access
}

moved {
  from = postgresql_default_privileges.table_access["dev"]
  to   = module.dev_db.postgresql_default_privileges.table_access
}

moved {
  from = postgresql_default_privileges.table_access["prod"]
  to   = module.prod_db.postgresql_default_privileges.table_access
}

moved {
  from = postgresql_grant.db_access["dev"]
  to   = module.dev_db.postgresql_grant.db_access
}

moved {
  from = postgresql_grant.db_access["prod"]
  to   = module.prod_db.postgresql_grant.db_access
}

moved {
  from = postgresql_grant.revoke_public["dev"]
  to   = module.dev_db.postgresql_grant.revoke_public
}
moved {
  from = postgresql_grant.revoke_public["prod"]
  to   = module.prod_db.postgresql_grant.revoke_public
}

moved {
  from = postgresql_role.quri_db_role["dev"]
  to   = module.dev_db.postgresql_role.role
}
moved {
  from = postgresql_role.quri_db_role["prod"]
  to   = module.prod_db.postgresql_role.role
}

moved {
  from = random_password.quri_db_role["dev"]
  to   = module.dev_db.random_password.password
}
moved {
  from = random_password.quri_db_role["prod"]
  to   = module.prod_db.random_password.password
}

moved {
  from = digitalocean_database_connection_pool.per_db["dev"]
  to   = module.dev_db.digitalocean_database_connection_pool.pool
}

moved {
  from = digitalocean_database_connection_pool.per_db["prod"]
  to   = module.prod_db.digitalocean_database_connection_pool.pool
}
