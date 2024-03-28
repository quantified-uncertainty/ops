This repository contains configs that set up QURI infrastructure.

# Terraform

Cloud infrastructure is provisioned by [Terraform](https://www.terraform.io/).

See [terraform/README.md](./terraform/README.md) for details.

# Kubernetes

`./k8s` contains ArgoCD application manifests (in `./k8s/app-manifests`) and app definitions themselves, usually as Helm charts (in `./k8s/apps`).
