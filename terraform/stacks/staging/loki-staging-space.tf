# DigitalOcean Spaces bucket for staging Loki storage
resource "digitalocean_spaces_bucket" "loki_staging" {
  name = "quri-loki-staging"
  acl  = "private"
}

# Create the loki-staging namespace
resource "kubernetes_namespace" "loki_staging" {
  metadata {
    name = "loki-staging"
  }

  depends_on = [digitalocean_kubernetes_cluster.staging]
}

# Create Kubernetes secret for staging Loki storage
resource "kubernetes_secret" "loki_staging" {
  metadata {
    name      = "loki-storage-secrets-staging"
    namespace = "loki-staging"
  }

  data = {
    s3-bucketName        = digitalocean_spaces_bucket.loki_staging.name
    s3-endpoint          = digitalocean_spaces_bucket.loki_staging.endpoint
    s3-accessKeyId       = data.onepassword_item.do_spaces_api_key.username
    s3-secretAccessKey   = data.onepassword_item.do_spaces_api_key.password
  }

  depends_on = [
    digitalocean_spaces_bucket.loki_staging,
    kubernetes_namespace.loki_staging
  ]
}
