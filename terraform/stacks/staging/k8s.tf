resource "digitalocean_kubernetes_cluster" "staging" {
  name    = "staging"
  region  = "nyc1"
  version = "1.31.9-do.3"
  ha      = false  # Single node for staging to save costs

  # Disable registry integration for staging
  registry_integration = false

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"  # Smaller nodes for staging
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 2
  }

  lifecycle {
    prevent_destroy = false  # Allow destruction for staging
  }
}

