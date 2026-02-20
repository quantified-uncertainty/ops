# 1Password secrets references
data "onepassword_item" "server_api_key" {
  vault = module.providers.op_vault
  title = "Longtermwiki LONGTERMWIKI_SERVER_API_KEY"
}

# Create namespace
resource "kubernetes_namespace" "longtermwiki" {
  metadata {
    name = local.k8s_namespace
  }
}

# Kubernetes secret with all environment variables
resource "kubernetes_secret" "longtermwiki_env" {
  metadata {
    namespace = local.k8s_namespace
    name      = "longtermwiki-env"
  }

  data = {
    DATABASE_URL                = module.database.bouncer_url
    LONGTERMWIKI_SERVER_API_KEY = data.onepassword_item.server_api_key.password
  }

  depends_on = [kubernetes_namespace.longtermwiki]
}
