output "prod_db_direct_url" {
  value     = module.prod_db.direct_url
  sensitive = true
}

output "dev_db_direct_url" {
  value     = module.dev_db.direct_url
  sensitive = true
}
