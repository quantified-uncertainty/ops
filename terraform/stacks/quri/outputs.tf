output "prod_db_direct_url" {
  value     = module.prod_db.direct_url
  sensitive = true
}

output "dev_db_direct_url" {
  value     = module.dev_db.direct_url
  sensitive = true
}

output "prod_db_prisma_url" {
  value     = "${module.prod_db.bouncer_url}&pgbouncer=true"
  sensitive = true
}

output "dev_db_prisma_url" {
  value     = "${module.dev_db.bouncer_url}&pgbouncer=true"
  sensitive = true
}
