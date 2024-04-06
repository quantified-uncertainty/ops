resource "digitalocean_kubernetes_cluster" "quri" {
  name    = "quri"
  region  = "nyc1"
  version = "1.29.1-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 3
    max_nodes  = 5
  }

  lifecycle {
    prevent_destroy = true
  }
}
