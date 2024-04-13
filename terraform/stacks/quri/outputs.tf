output "prod_db_direct_url" {
  value     = module.prod_db.direct_url
  sensitive = true
}

output "dev_db_direct_url" {
  value     = module.dev_db.direct_url
  sensitive = true
}

output "prod_db_prisma_url" {
  value     = local.prod_db_prisma_url
  sensitive = true
}

output "dev_db_prisma_url" {
  value     = local.dev_db_prisma_url
  sensitive = true
}
