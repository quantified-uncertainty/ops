resource "heroku_app" "main" {
  name   = "guesstimate"
  region = "us"

  organization {
    name = "quantified-uncertainty-researc"
  }
}

resource "heroku_addon" "db" {
  app_id = heroku_app.main.id
  plan   = "heroku-postgresql:standard-0"
}
