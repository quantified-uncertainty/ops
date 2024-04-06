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
    namespace = "metaforecast"
    name      = "metaforecast-search-es-elastic-user"
  }
}

module "metaforecast" {
  source = "git::https://github.com/quantified-uncertainty/metaforecast.git//tf?depth=1&ref=elastic"

  metaforecast_env = {
    GOODJUDGMENTOPENCOOKIE  = data.onepassword_item.goodjudgmentopen_cookie.password
    GOOGLE_API_KEY          = data.onepassword_item.google_api_key.password
    HYPERMINDCOOKIE         = data.onepassword_item.hypermind_cookie.password
    INFER_COOKIE            = data.onepassword_item.infer_cookie.password
    SECRET_BETFAIR_ENDPOINT = data.onepassword_item.secret_betfair_endpoint.password
    IMGUR_BEARER            = data.onepassword_item.imgur_bearer.password

    NEXT_PUBLIC_SITE_URL = "https://metaforecast.org"

    ELASTIC_HOST     = "https://metaforecast-elastic.k8s.quantifieduncertainty.org"
    ELASTIC_INDEX    = "metaforecast"
    ELASTIC_USER     = "elastic"
    ELASTIC_PASSWORD = data.kubernetes_secret.elastic.data["elastic"]
  }
}

import {
  to = module.metaforecast.vercel_project.main
  id = "prj_PamguVNGEisOv9VJni6FKylJPUiA"
}

import {
  to = module.metaforecast.digitalocean_database_cluster.main
  id = "09b083f5-1ed3-4259-bbca-b4870a77ffe4"
}

import {
  to = module.metaforecast.heroku_app.backend
  id = "metaforecast-backend"
}
