import {
  to = github_repository_environment.preview
  id = "squiggle:Preview"
}

import {
  to = github_repository_environment.production
  id = "squiggle:Production"
}

resource "github_repository_environment" "preview" {
  environment = "Preview"
  repository  = "squiggle"
}

resource "github_repository_environment" "production" {
  environment = "Production"
  repository  = "squiggle"
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "production" {
  repository     = "squiggle"
  environment    = github_repository_environment.production.environment
  branch_pattern = "main"
}

resource "github_actions_secret" "vercel_api_token" {
  repository      = "squiggle"
  secret_name     = "VERCEL_API_TOKEN"
  plaintext_value = var.vercel_api_token
}

resource "github_actions_environment_secret" "database_url" {
  // Used by "prisma migrate" action.
  repository      = "squiggle"
  secret_name     = "DATABASE_DIRECT_URL"
  environment     = github_repository_environment.production.environment
  plaintext_value = local.database_urls.prod.direct_url
}

resource "github_actions_environment_secret" "database_dev_url" {
  repository      = "squiggle"
  secret_name     = "DATABASE_DIRECT_URL"
  environment     = github_repository_environment.preview.environment
  plaintext_value = local.database_urls.dev.direct_url
}
