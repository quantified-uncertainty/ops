resource "vercel_project" "relative-values" {
  name           = "relative-values"
  root_directory = "packages/relative-values"
  git_repository = {
    production_branch = "master"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }
}

resource "vercel_project" "hub" {
  name           = "quri-hub"
  root_directory = "packages/hub"
  git_repository = {
    production_branch = "develop"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }

  environment = [
    {
      key    = "DATABASE_URL"
      value  = digitalocean_database_cluster.quri.uri
      target = ["production", "preview"]
    },
    {
      key    = "GITHUB_CLIENT_ID"
      value  = var.github_client_id
      target = ["production"]
    },
    {
      key    = "GITHUB_CLIENT_SECRET"
      value  = var.github_client_secret
      target = ["production"]
    },
    {
      key    = "SENDGRID_KEY"
      value  = var.sendgrid_key
      target = ["production", "preview"]
    },
    {
      key    = "EMAIL_FROM"
      value  = var.hub_email_from
      target = ["production", "preview"]
    },
    {
      key    = "NEXTAUTH_SECRET"
      value  = var.hub_nextauth_secret
      target = ["production", "preview"]
    },
  ]

  # close to digitalocean_database_cluster.quri
  serverless_function_region = "iad1"
}

resource "vercel_project_domain" "squiggle-hub-org" {
  domain     = "squiggle-hub.org"
  project_id = vercel_project.hub.id
}

resource "vercel_project_domain" "www-squiggle-hub-org" {
  domain               = "www.squiggle-hub.org"
  redirect             = "squiggle-hub.org"
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-website.id
}

resource "vercel_project_domain" "squiggle-hub-com" {
  domain               = "squiggle-hub.com"
  redirect             = "squiggle-hub.org"
  redirect_status_code = 308
  project_id           = vercel_project.hub.id
}

resource "vercel_project_domain" "www-squiggle-hub-com" {
  domain               = "www.squiggle-hub.com"
  redirect             = "squiggle-hub.org"
  redirect_status_code = 308
  project_id           = vercel_project.squiggle-website.id
}
