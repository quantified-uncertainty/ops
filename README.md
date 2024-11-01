This repository contains the configs that describe QURI infrastructure.

It has two major components: Terraform and Kubernetes.

# Terraform

Cloud infrastructure is provisioned by [Terraform](https://www.terraform.io/).

See [terraform/README.md](./terraform/README.md) for details.

# Kubernetes

`./k8s` contains ArgoCD application manifests (in `./k8s/app-manifests`) and app definitions themselves, usually as Helm charts (in `./k8s/apps`).
