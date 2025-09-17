Roast My Post Staging Environment Setup

Action plan for adding a staging/test environment for the Roast My Post application.

STEPS

1. Create staging database in Terraform ✅ COMPLETED
   - Add staging database module to terraform/stacks/roast-my-post/db.tf
   - Apply Terraform changes: cd terraform/stacks/roast-my-post && terraform plan && terraform apply
   - Used pool_size = 2 to stay within database connection limits (22/25 total)

2. Create staging environment secret in Terraform ✅ COMPLETED
   - Add staging database outputs to terraform/stacks/roast-my-post/outputs.tf for connection string
   - Add Kubernetes secret resource in terraform/stacks/roast-my-post/secrets.tf for roast-my-post-staging-env secret
   - Configure secret in roast-my-post-staging namespace with staging database connection
   - Copy all environment variables from production secret but update DATABASE_URL to staging database
   - Apply Terraform changes: terraform apply -target=kubernetes_namespace.roast_my_post_staging -target=kubernetes_secret.roast_my_post_staging_env

3. Add staging app to ArgoCD
   - Update k8s/app-manifests/values.yaml to include roast-my-post-staging app
   - Configure staging namespace and URL
   - Note: Both apps will initially track same Git repo/branch for Helm chart
   - Different image tags will be set via ArgoCD CLI to deploy different versions
   - Production uses main branch images, staging uses staging branch images

4. Deploy via ArgoCD
   - Sync app-of-apps to create staging application: argocd app sync app-of-apps
   - Configure staging domain via ArgoCD: argocd app set roast-my-post-staging --helm-set hosts[0]=staging.roastmypost.org
   - Set staging image tags: argocd app set roast-my-post-staging --helm-set image.tag=staging-branch
   - Sync staging app: argocd app sync roast-my-post-staging

5. Verify deployment
   - Check staging app is accessible at https://staging.roastmypost.org
   - Verify database migrations ran successfully
   - Check application logs for errors

NOTES

- Staging uses separate database to avoid production interference
- Same Helm chart deployed to different namespaces with different Git branch tracking
- Production app tracks main branch, staging app tracks staging branch
- SSL certificates automatically provisioned for staging domain
- Consider reduced resource allocations for staging to save costs
