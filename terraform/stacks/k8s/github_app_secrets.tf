# These secrets are used by Argo Workflows configuration to run GitHub Actions-like CI workflows.
# Our custom GitHub app uses these credentials to obtain a short-lived GITHUB_TOKEN, which is used to authenticate against GitHub API.
# Specifically, that token can be useful for:
# - (TODO) posting comments to PRs
# - (TODO) updating checks in PRs
# Or anything else that's often done from GitHub Actions, but in our case it's done from Argo Workflows.
#
# Btw, we can't use this secret for uploading images to Github Container Registry, because it's not a personal access token.
# I've spent ~4 hours trying to figure that out, and ended up switching to DigitalOcean Container Registry.

# We set up two secrets: one for quantified-uncertainty org, and another for getguesstimate org.
# This is because we have two GitHub apps, one for each org.
# We could use a single app, but then we'd have to publish it, and our apps are currently private.
# For reference, here are the apps:
# - https://github.com/apps/quri-integrations
# - https://github.com/apps/quri-integrations-for-guesstimate

data "onepassword_item" "quri_integrations_for_guesstimate_github_app_private_key" {
  vault = module.providers.op_vault
  title = "QURI Integrations for Guesstimate GitHub App Private Key"
}

data "onepassword_item" "quri_integrations_for_quri_github_app_private_key" {
  vault = module.providers.op_vault
  title = "QURI Integrations GitHub App Private Key"
}

# TODO - bad resource name, should mention guesstimate
resource "kubernetes_secret" "argo_workflows_github_token_credentials" {
  metadata {
    name      = "quri-integrations-for-getguesstimate-github-app"
    namespace = var.ci_namespace
  }

  data = {
    app-id          = var.github_app_guesstimate.app_id
    installation-id = var.github_app_guesstimate.installation_id
    private-key     = data.onepassword_item.quri_integrations_for_guesstimate_github_app_private_key.note_value
  }
}

resource "kubernetes_secret" "argo_workflows_github_quri_token_credentials" {
  metadata {
    # name is intentionally long, so that we could interpolate org name (guesstimate or quantified-uncertainty) in Argo Workflows
    name      = "quri-integrations-for-quantified-uncertainty-github-app"
    namespace = var.ci_namespace
  }

  data = {
    app-id          = var.github_app_quri.app_id
    installation-id = var.github_app_quri.installation_id
    private-key     = data.onepassword_item.quri_integrations_for_quri_github_app_private_key.note_value
  }
}
