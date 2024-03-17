# https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/
# TODO: configure a secret, see https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/#2-configure-argo-cd-with-the-webhook-secret-optional
resource "github_organization_webhook" "argo_cd" {
  configuration {
    url          = "${var.argo_cd_endpoint}/api/webhook"
    content_type = "json"
  }

  events = ["push"]
}

data "onepassword_item" "slack_alerts_webhook" {
  vault = module.providers.op_vault
  title = "Slack alerts webhook"
}

resource "kubernetes_secret" "slack_alerts" {
  metadata {
    name = "slack-alerts"
    namespace = "prometheus"
  }

  data = {
    slack-alerts = data.onepassword_item.slack_alerts_webhook.password
  }
}
