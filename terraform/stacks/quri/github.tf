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

data "onepassword_item" "argo_cd_auth_token" {
  vault = module.providers.op_vault
  title = "Argo CD github_actions_bot token"
}

resource "github_actions_secret" "argo_cd_auth_token" {
  repository      = "squiggle"
  secret_name     = "ARGOCD_AUTH_TOKEN"
  plaintext_value = data.onepassword_item.argo_cd_auth_token.password
}
