resource "digitalocean_kubernetes_cluster" "quri" {
  name    = "QURI"
  region  = "nyc1"
  version = "1.29.1-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb"
    node_count = 1
  }
}
