# # Not used yet - we're still using Heroku for Guesstimate prod
# module "db" {
#   source = "../../modules/database"

#   providers = {
#     postgresql = postgresql.quri
#   }

#   cluster   = digitalocean_database_cluster.quri
#   name      = "guesstimate"
#   database  = "guesstimate"
#   role      = "guesstimate_role"
#   pool_size = 5
#   create    = true
# }
