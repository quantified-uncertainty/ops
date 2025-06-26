# Add database URL as a GitHub Actions secret for migrations
# Commented out until we have a valid GitHub token
# resource "github_actions_secret" "database_url" {
#   repository      = "roast-my-post"
#   secret_name     = "DATABASE_URL"
#   plaintext_value = module.database.bouncer_url
# }

# # Add Prisma database URL for migrations that require it
# resource "github_actions_secret" "prisma_database_url" {
#   repository      = "roast-my-post"
#   secret_name     = "PRISMA_DATABASE_URL"
#   plaintext_value = module.database.direct_url
# }