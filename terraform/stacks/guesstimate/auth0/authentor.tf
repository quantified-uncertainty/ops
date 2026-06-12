data "auth0_tenant" "tenant" {}

resource "auth0_client" "authentor" {
  name     = "Guesstimate Authentor"
  app_type = "non_interactive"

  # Matches the live tenant setting; declared so terraform doesn't try to
  # disable it on unrelated applies.
  cross_origin_auth = true
}


resource "auth0_client_grant" "authentor" {
  client_id = auth0_client.authentor.id
  audience  = "https://${data.auth0_tenant.tenant.domain}/api/v2/"
  scopes    = ["read:users", "create:users", "create:user_tickets"]
}

resource "auth0_client_credentials" "authentor" {
  client_id             = auth0_client.authentor.client_id
  authentication_method = "client_secret_post"
}
