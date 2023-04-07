terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.19.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "postgresql" {
  host            = "localhost"
  port            = 5432
  sslmode         = "disable"
  connect_timeout = 15
}

provider "digitalocean" {
  token = var.do_token
}

resource "postgresql_database" "quri_db" {
  name = "quri"
}

resource "digitalocean_project" "quri" {
  name        = "QURI"
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
