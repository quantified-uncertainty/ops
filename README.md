This repository contains configs that set up QURI databases, domains and various deployments.

Configs are written in [Terraform](https://www.terraform.io/).

To use it, you'll need two additional things:

- `secrets.auto.tfvars` file (can't be committed to the repo for obvious reasons)
- `terraform.tfstate` file (absolutely necessary, **don't try to apply the configs if you don't have it!**)

Eventually we'll store the tfstate file on Terraform Cloud or somewhere else. For now you'll have to ask @berekuk for the file and then send it back if you changed anything.
