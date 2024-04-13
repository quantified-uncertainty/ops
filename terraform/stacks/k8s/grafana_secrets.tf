data "onepassword_item" "grafana_admin" {
  vault = module.providers.op_vault
  title = "Grafana admin"
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name = "grafana-credentials" # must be in sync with `k8s/apps/prometheus/values.yaml`
    # This namespace should already exist. This might make the bootstrapping of the entire configuration awkward.
    # (we could create a namespace with Terraform if we ever need to reset the entire cluster, but that's not very probable)
    namespace = "prometheus" # must be in sync with `k8s/app-manifests/prometheus-stack.yaml`
  }

  data = {
    admin-user     = data.onepassword_item.grafana_admin.username
    admin-password = data.onepassword_item.grafana_admin.password
  }
}
