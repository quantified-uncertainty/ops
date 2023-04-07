terraform {
  cloud {
    organization = "quantified-uncertainty"
    workspaces {
      name = "ops"
    }
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.4"
    }
  }
}

variable "do_token" {}
provider "digitalocean" {
  token = var.do_token
}

variable "vercel_api_token" {}
provider "vercel" {
  api_token = var.vercel_api_token
  team      = "quantified-uncertainty"
}

resource "digitalocean_project" "metaforecast" {
  name        = "metaforecast.org"
  description = "Metaforecast.org resources."
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

resource "vercel_project" "quri-api" {
  name           = "quri-api"
  root_directory = "packages/api-server"
  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }

  environment = [
    {
      key    = "DATABASE_URL"
      value  = digitalocean_database_cluster.quri.uri
      target = ["production", "development", "preview"]
    }
  ]
}


resource "vercel_project" "relative-values" {
  name           = "relative-values"
  root_directory = "packages/relative-values"
  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project" "squiggle-components" {
  name           = "squiggle-components"
  root_directory = "packages/components"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project" "squiggle-website" {
  name           = "squiggle-website"
  root_directory = "packages/website"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project_domain" "squiggle-website-wwwless" {
  domain               = "squiggle-language.com"
  redirect             = "www.squiggle-language.com"
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-website.id
}

resource "vercel_project_domain" "squiggle-website" {
  domain     = "www.squiggle-language.com"
  project_id = vercel_project.squiggle-website.id
}

resource "vercel_project_domain" "squiggle-website-preview" {
  domain     = "preview.squiggle-language.com"
  git_branch = "develop"
  project_id = vercel_project.squiggle-website.id
}

resource "vercel_project" "squiggle-stories" {
  name      = "squiggle-stories"
  framework = "nextjs"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle-stories"
    type              = "github"
  }
}

resource "vercel_project" "metaforecast" {
  name      = "metaforecast"
  framework = "nextjs"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/metaforecast"
    type              = "github"
  }
}

resource "vercel_project" "guesstimate-app" {
  name      = "guesstimate-app"
  framework = "nextjs"

  git_repository = {
    production_branch = "nextjs"
    repo              = "berekuk/guesstimate-app"
    type              = "github"
  }
}

resource "vercel_project" "squiggle-tweaker" {
  name      = "squiggle-tweaker"
  framework = "nextjs"

  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle-tweaker"
    type              = "github"
  }
}
