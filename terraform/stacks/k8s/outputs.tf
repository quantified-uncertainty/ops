output "registry_password" {
  value     = random_password.registry_password.result
  sensitive = true
}
