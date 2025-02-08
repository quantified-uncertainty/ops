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
  plaintext_value = module.providers.vercel_api_token # necessary for some github actions (?)
}

resource "github_actions_environment_secret" "database_url" {
  // Used by "prisma migrate" action.
  repository      = "squiggle"
  secret_name     = "DATABASE_DIRECT_URL"
  environment     = github_repository_environment.production.environment
  plaintext_value = module.prod_db.direct_url
}

resource "github_actions_environment_secret" "database_dev_url" {
  repository      = "squiggle"
  secret_name     = "DATABASE_DIRECT_URL"
  environment     = github_repository_environment.preview.environment
  plaintext_value = module.dev_db.direct_url
}

resource "github_actions_secret" "vercel_org_id" {
  repository      = "squiggle"
  secret_name     = "VERCEL_ORG_ID"
  plaintext_value = data.onepassword_item.vercel_team_id.password
}

resource "github_actions_secret" "vercel_project_ids" {
  for_each = {
    components : vercel_project.squiggle-components.id
  }
  repository      = "squiggle"
  secret_name     = "VERCEL_${upper(each.key)}_PROJECT_ID"
  plaintext_value = each.value
}

resource "github_actions_secret" "vsce_pat" {
  repository      = "squiggle"
  secret_name     = "VSCE_PAT"
  plaintext_value = data.onepassword_item.vsce_pat.password
}

resource "github_team" "k8s_admins" {
  name        = "Kubernetes Admins"
  description = "SSO in Kubernetes (e.g. for Argo CD) relies on this team for authorization."
  privacy     = "closed"
}

resource "github_team_members" "k8s_admins" {
  team_id = github_team.k8s_admins.id

  members {
    username = "OAGr"
    role     = "maintainer"
  }

  members {
    username = "berekuk"
    role     = "maintainer"
  }
}

data "onepassword_item" "quri_integrations_for_quri_github_app_private_key" {
  vault = module.providers.op_vault
  title = "QURI Integrations GitHub App Private Key"
}

resource "github_actions_variable" "app_id" {
  repository      = "squiggle"
  variable_name   = "APP_ID"
  value           = var.github_app_quri.app_id
}

resource "github_actions_secret" "app_private_key" {
  repository      = "squiggle"
  secret_name     = "APP_PRIVATE_KEY"
  plaintext_value = data.onepassword_item.quri_integrations_for_quri_github_app_private_key.note_value
}
