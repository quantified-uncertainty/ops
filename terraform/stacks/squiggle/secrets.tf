data "terraform_remote_state" "quri" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "quri-tf-state-us-east-1"
    key    = "stacks/quri.tfstate"
  }
}

resource "kubernetes_secret" "main" {
  metadata {
    name      = "squiggle-hub-env"
    namespace = "squiggle"
  }

  data = {
    # Only DATABASE_URL is necessary for now, for squiggle-build-runner image.
    DATABASE_URL = data.terraform_remote_state.quri.outputs.prod_db_prisma_url
  }
}
