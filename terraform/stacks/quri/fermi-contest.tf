resource "vercel_project" "fermi_contest" {
  name           = "fermi-contest-2025-02"
  root_directory = "apps/fermi-contest-2025-02"
  git_repository = {
    production_branch = "main"
    repo              = "quantified-uncertainty/squiggle"
    type              = "github"
  }

  environment = [
    {
      key    = "ENABLE_EXPERIMENTAL_COREPACK"
      value  = "1"
      target = ["production", "preview"]
    },
  ]
}
