variable "argo_cd_endpoint" {
  default = "https://argo.k8s.quantifieduncertainty.org"
}

variable "github_app_guesstimate" {
  default = {
    app_id          = 856293   # TODO - could this be obtained from a data source?
    installation_id = 48456163 # TODO - and this?
  }
}

variable "ci_namespace" {
  default = "quri-ci"
  description = "Kubernetes namespace that's used for CI workflows. Will be used to store secrets."
}
