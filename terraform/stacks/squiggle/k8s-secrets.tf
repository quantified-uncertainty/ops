resource "kubernetes_secret" "main" {
  metadata {
    name      = "squiggle-hub-env"
    namespace = "squiggle"
  }

  data = {
    DATABASE_URL = data.terraform_remote_state.quri.outputs.prod_db_prisma_url
    # run evals with root permissions
    CLI_MODE = "true"
    # FIXME - copy-pasted from squiggle-hub.tf in quri stack (we need to migrate squiggle resources to this stack)
    CLI_USER_EMAIL = "me@berekuk.ru"
    ROOT_EMAILS    = "me@berekuk.ru"
  }
}
