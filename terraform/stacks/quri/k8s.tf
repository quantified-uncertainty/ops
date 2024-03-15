resource "digitalocean_kubernetes_cluster" "quri" {
  name    = "quri"
  region  = "nyc1"
  version = "1.29.1-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"
    node_count = 2
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_container_registry" "main" {
  name                   = "quri"
  subscription_tier_slug = "starter"
}
