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

resource "digitalocean_database_connection_pool" "main" {
  cluster_id = digitalocean_database_cluster.quri.id
  name       = "main"
  mode       = "transaction"
  size       = 20
  db_name    = "defaultdb"
  user       = "doadmin"
}

resource "github_actions_secret" "database_url" {
  // used by "prisma migrate" action
  repository      = "squiggle"
  secret_name     = "DATABASE_URL"
  plaintext_value = digitalocean_database_cluster.quri.uri
}
