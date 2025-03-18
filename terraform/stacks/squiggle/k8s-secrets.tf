resource "kubernetes_secret" "main" {
  metadata {
    name      = "squiggle-hub-env"
    namespace = "squiggle"
  }

  data = {
    DATABASE_URL = data.terraform_remote_state.quri.outputs.prod_db_prisma_url
    # run evals with root permissions
    CLI_MODE          = "true"
    CLI_USER_EMAIL    = var.hub_cli_user_email
    ROOT_EMAILS       = var.hub_root_emails
    ANTHROPIC_API_KEY = data.onepassword_item.anthropic_api_key.password
  }
}
