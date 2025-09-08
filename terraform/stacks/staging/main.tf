locals {
  # Staging environment configuration
  environment = "staging"
  
  # Domains
  roast_my_post_domain = "staging.roast-my-post.com"
  squiggle_domain      = "staging.squiggle-language.com"
  guesstimate_domain   = "staging.getguesstimate.com"
  
  # Database configuration
  db_name = "staging"
  db_user = "staging_user"
  
  # Kubernetes namespace
  k8s_namespace = "staging"
}

# DigitalOcean project for staging resources
resource "digitalocean_project" "staging" {
  name        = "QURI Staging"
  description = "Staging environment for QURI applications"
  purpose     = "Web Application"
  environment = "Staging"
}

