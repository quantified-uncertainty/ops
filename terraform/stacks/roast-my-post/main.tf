locals {
  domain = "roastmypost.org"  # Adjust this to your actual domain
  
  # Database configuration
  db_name = "roastmypost"
  db_user = "roastmypost"
  
  # Kubernetes namespace
  k8s_namespace = "roast-my-post"
}

# DigitalOcean project to group all resources
resource "digitalocean_project" "main" {
  name        = "Roast My Post"
  description = "AI-powered document review and feedback platform"
  purpose     = "Web Application"
  environment = "Production"
}