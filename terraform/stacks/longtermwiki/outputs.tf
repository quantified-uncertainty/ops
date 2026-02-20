output "database_url" {
  value     = module.database.bouncer_url
  sensitive = true
}

output "database_url_direct" {
  value     = module.database.direct_url
  sensitive = true
}
