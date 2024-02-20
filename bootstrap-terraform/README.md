This module bootstraps Terraform state on AWS, with S3 bucket and DynamoDB lock table.

It's a straightforward application of https://registry.terraform.io/modules/trussworks/bootstrap/aws/latest module. It creates two key resources:

1. S3 bucket for Terraform state.
2. DynamoDB lock table for locking the state.

(there are a few more details, like a separate log bucket and configuration)

Hopefully we'll only have to do it once. I (@berekuk) ran this on 2024-02-20.

The state for this is necessarily local. I'm not sure if the state includes anything sensitive, it's possible that it can be published, but I opted not to commit it to repo.
