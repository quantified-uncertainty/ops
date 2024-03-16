resource "digitalocean_spaces_bucket" "loki" {
  name = "quri-loki"
  acl  = "private"
}

resource "kubernetes_namespace" "loki" {
  metadata {
    name = "loki"
  }
}

resource "kubernetes_secret" "loki" {
  metadata {
    name      = "loki-storage-secrets"
    namespace = "loki"
  }

  data = {
    s3-bucketName        = digitalocean_spaces_bucket.loki.name
    s3-endpoint        = digitalocean_spaces_bucket.loki.endpoint
    s3-accessKeyId     = data.onepassword_item.do_spaces_api_key.username
    s3-secretAccessKey = data.onepassword_item.do_spaces_api_key.password
  }
}
