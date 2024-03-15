# https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/
# TODO: configure a secret, see https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/#2-configure-argo-cd-with-the-webhook-secret-optional
resource "github_organization_webhook" "argo_cd" {
  configuration {
    url          = "${var.argo_cd_endpoint}/api/webhook"
    content_type = "application/json"
  }

  events = ["push"]
}
