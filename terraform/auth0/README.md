# Terraform configs for managing Auth0

This is stored separately from our main Terraform configuration, because:

1. Auth0 management credentials are short-lived, and obtaining a new `access_token` for each Terraform run would be annoying
   - There's probably a way around that, though.
2. I want to experiment with "many small state files" approach to Terraform which is generally recommended.
