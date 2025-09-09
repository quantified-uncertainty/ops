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

# Configure kubectl to use the staging cluster
resource "null_resource" "configure_kubectl" {
  depends_on = [digitalocean_kubernetes_cluster.staging]

  provisioner "local-exec" {
    command = "doctl kubernetes cluster kubeconfig save staging --set-current-context"
  }

  triggers = {
    cluster_id = digitalocean_kubernetes_cluster.staging.id
  }
}

# Deploy ArgoCD to bootstrap GitOps
resource "null_resource" "deploy_argocd" {
  depends_on = [null_resource.configure_kubectl]

  provisioner "local-exec" {
    command = <<-EOT
      # Create argocd namespace first
      kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
      # Deploy ArgoCD with explicit namespace
      kubectl apply -k ../../../k8s/apps/argocd/overlays/staging -n argocd
      # Wait for deployment to exist first
      echo "Waiting for argocd-server deployment to be created..."
      while ! kubectl get deployment argocd-server -n argocd >/dev/null 2>&1; do
        echo "Deployment not found yet, waiting..."
        sleep 5
      done
      echo "Deployment found, waiting for it to be available..."
      kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
    EOT
  }

  triggers = {
    cluster_id = digitalocean_kubernetes_cluster.staging.id
  }
}

# Deploy staging app-of-apps for automated infrastructure
resource "null_resource" "deploy_staging_apps" {
  depends_on = [
    null_resource.deploy_argocd,
    kubernetes_secret.loki_staging
  ]

  provisioner "local-exec" {
    command = <<-EOT
      # Deploy app-of-apps
      kubectl apply -f ../../../k8s/app-of-apps-staging.yaml
      
      # Wait a bit for ArgoCD to pick up the application
      sleep 30
      
      # Sync the app-of-apps to deploy all infrastructure
      kubectl patch application app-of-apps-staging -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"hook":{},"apply":{"force":true}}}}}'
    EOT
  }

  triggers = {
    cluster_id = digitalocean_kubernetes_cluster.staging.id
    bucket_name = digitalocean_spaces_bucket.loki_staging.name
  }
}

