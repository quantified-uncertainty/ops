resource "vercel_project" "docs" {
  name      = "guesstimate-docs"
  framework = "nextjs"

  git_repository = {
    production_branch = "main"
    repo              = "getguesstimate/guesstimate-docs"
    type              = "github"
  }
}

module "docs_domain" {
  source = "../../modules/vercel-domain"

  domain     = "getguesstimate.com"
  project_id = vercel_project.docs.id
  www        = false
  subdomain  = "docs"
}
