variable "domain" {
  default = "getguesstimate.com"
}

# These are for production.
variable "auth0_domain" {
  default = "guesstimate.auth0.com"
}

variable "auth0_connection_name" {
  # This is a production name. It'd be hard to change it, so we're stuck with it.
  default = "Guesstimate-test"
}

variable "api_domain" {
  default = "api.getguesstimate.com"
}

variable "k8s_namespace" {
  # Should match the Kubernetes namespace where Guesstimate is deployed. This
  # namespace would usually be created by Argo CD Application, but there's no
  # harm in checking it here too.
  default = "guesstimate"
}

variable "k8s_backend_env_secret" {
  # Should match Kubernetes manifests for guesstimate-server.
  default = "guesstimate-server"
}
