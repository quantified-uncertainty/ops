resource "digitalocean_kubernetes_cluster" "quri" {
  name    = "quri"
  region  = "nyc1"
  version = "1.29.1-do.0"
  ha      = true

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 4
    max_nodes  = 5
  }

  lifecycle {
    prevent_destroy = true
  }
}

// Pool for running CI and some Argo services, set aside for affinity. It has a
// taint to prevent other workloads from running on it.
// Kaniko builds in particular can consume a lot of memory, and make the node
// unstable, so it's dangerous to run them on the same nodes as other workloads.
resource "digitalocean_kubernetes_node_pool" "ci_cd" {
  cluster_id = digitalocean_kubernetes_cluster.quri.id

  name       = "build-servers"
  size       = "s-2vcpu-4gb"
  node_count = 1

  labels = {
    dedicated = "builds"
  }

  taint {
    key    = "dedicated"
    value  = "builds"
    effect = "NoSchedule"
  }
}
