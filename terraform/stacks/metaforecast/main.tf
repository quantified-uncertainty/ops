locals {
  domain                = "metaforecast.org"
  elastic_host          = "https://metaforecast-elastic.k8s.quantifieduncertainty.org"
  elastic_k8s_namespace = "metaforecast"
  elastic_k8s_secret    = "metaforecast-search-es-elastic-user"
}

resource "digitalocean_project" "main" {
  name        = local.domain
  description = "Metaforecast resources."
}

data "onepassword_item" "goodjudgmentopen_cookie" {
  vault = "Metaforecast"
  title = "Good Judgment Open cookie"
}

data "onepassword_item" "google_api_key" {
  vault = "Metaforecast"
  title = "Google API key"
}

data "onepassword_item" "hypermind_cookie" {
  vault = "Metaforecast"
  title = "Hypermind cookie"
}

data "onepassword_item" "infer_cookie" {
  vault = "Metaforecast"
  title = "Infer cookie"
}

data "onepassword_item" "secret_betfair_endpoint" {
  vault = "Metaforecast"
  title = "Secret Betfair endpoint"
}

data "onepassword_item" "imgur_bearer" {
  vault = "Metaforecast"
  title = "Imgur bearer"
}

# Elasticsearch must be configured in Kubernetes before applying this stack.
data "kubernetes_secret" "elastic" {
  metadata {
    namespace = local.elastic_k8s_namespace
    name      = local.elastic_k8s_secret
  }
}

module "metaforecast" {
  source = "git::https://github.com/quantified-uncertainty/metaforecast.git//tf?depth=1"

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

module "domain" {
  source = "../../modules/vercel-domain"

  domain     = local.domain
  project_id = module.metaforecast.vercel_project_id
  www        = false
}

resource "digitalocean_project_resources" "domain" {
  project   = digitalocean_project.main.id
  resources = module.domain.digitalocean_urns
}
