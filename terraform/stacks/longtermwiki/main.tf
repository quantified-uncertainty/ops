locals {
  app_name = "longtermwiki"
  region   = "nyc1"

  # Database configuration
  db_name = "longtermwiki"
  db_user = "longtermwiki"

  # Kubernetes namespace
  k8s_namespace = "longtermwiki"
}

# DigitalOcean project to group all resources
resource "digitalocean_project" "main" {
  name        = "Longtermwiki"
  description = "Dev server for longterm-wiki development"
  purpose     = "Web Application"
  environment = "Development"
}
