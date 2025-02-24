locals {
  domain                = "metaforecast.org"
  elastic_host          = "https://metaforecast-elastic.k8s.quantifieduncertainty.org"
  elastic_k8s_namespace = "metaforecast"

  # Contains credentials for default elastic user.
  # https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-users-and-roles.html
  elastic_k8s_secret = "metaforecast-search-es-elastic-user"
}

resource "digitalocean_project" "main" {
  name        = local.domain
  description = "Metaforecast resources."
}

# Elasticsearch must be configured in Kubernetes before applying this stack.
data "kubernetes_secret" "elastic" {
  metadata {
    namespace = local.elastic_k8s_namespace
    name      = local.elastic_k8s_secret
  }
}

module "metaforecast" {
  source = "git::https://github.com/quantified-uncertainty/squiggle.git//apps/metaforecast/ops/tf?depth=1"

  metaforecast_env = {
    GOODJUDGMENTOPENCOOKIE  = data.onepassword_item.goodjudgmentopen_cookie.password
    GOOGLE_API_KEY          = data.onepassword_item.google_api_key.password
    HYPERMINDCOOKIE         = data.onepassword_item.hypermind_cookie.password
    INFER_COOKIE            = data.onepassword_item.infer_cookie.password
    SECRET_BETFAIR_ENDPOINT = data.onepassword_item.secret_betfair_endpoint.password
    IMGUR_BEARER            = data.onepassword_item.imgur_bearer.password

    NEXT_PUBLIC_SITE_URL = "https://${local.domain}"

    ELASTIC_HOST     = local.elastic_host
    ELASTIC_INDEX    = "metaforecast"
    ELASTIC_USER     = "elastic"
    ELASTIC_PASSWORD = data.kubernetes_secret.elastic.data["elastic"]
  }

  digitalocean_project_id = digitalocean_project.main.id
}

# Create metaforecast.org domain on DigitalOcean and Vercel.
module "domain" {
  source = "../../modules/vercel-domain"

  domain     = local.domain
  project_id = module.metaforecast.vercel_project_id
  www        = false
}

# DigitalOcean domain belongs to the metaforecast DigitalOcean project.
resource "digitalocean_project_resources" "domain" {
  project   = digitalocean_project.main.id
  resources = module.domain.digitalocean_urns
}

# Kubernetes secret with metaforecast environment variables.
# It will be used by metaforecast Helm chart, to run background jobs.
resource "kubernetes_secret" "metaforecast_env" {
  metadata {
    namespace = "metaforecast"
    name      = "metaforecast-env" # matches the value of `envSecret` in metaforecast chart values.yaml
  }

  # copy-pasted from module.metaforecast.metaforecast_env
  # TODO - is there any way to simplify this?
  # metaforecast terraform module doesn't configure kubernetes, so we can't configure the secret there...
  data = {
    "GOODJUDGMENTOPENCOOKIE"  = data.onepassword_item.goodjudgmentopen_cookie.password
    "GOOGLE_API_KEY"          = data.onepassword_item.google_api_key.password
    "HYPERMINDCOOKIE"         = data.onepassword_item.hypermind_cookie.password
    "INFER_COOKIE"            = data.onepassword_item.infer_cookie.password
    "SECRET_BETFAIR_ENDPOINT" = data.onepassword_item.secret_betfair_endpoint.password
    "IMGUR_BEARER"            = data.onepassword_item.imgur_bearer.password

    "NEXT_PUBLIC_SITE_URL" = "https://${local.domain}"

    "ELASTIC_HOST"     = local.elastic_host
    "ELASTIC_INDEX"    = "metaforecast"
    "ELASTIC_USER"     = "elastic"
    "ELASTIC_PASSWORD" = data.kubernetes_secret.elastic.data["elastic"]

    # DB is created in metaforecast TF module and its url is exported as an output
    "METAFORECAST_DB_URL" = module.metaforecast.db_url
  }
}
