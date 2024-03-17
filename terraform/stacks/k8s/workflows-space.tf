resource "digitalocean_spaces_bucket" "workflows" {
  name = "quri-workflows-artifacts" # must match the bucket name in argo-workflows/values.yaml
  acl  = "private"
}

resource "kubernetes_secret" "workflows_artifacts" {
  metadata {
    name      = "workflows-artifacts-cred"
    namespace = "quri-ci"
  }

  data = {
    # TODO - we use the same key for both loki and workflows; DigitalOcean Spaces doesn't have granular permissions.
    # We should migrate to S3.
    accessKey     = data.onepassword_item.do_spaces_api_key.username
    secretKey = data.onepassword_item.do_spaces_api_key.password
  }
}
