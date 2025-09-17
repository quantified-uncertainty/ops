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

3. Add staging app to ArgoCD ✅ COMPLETED
   - Update k8s/app-manifests/values.yaml to include roast-my-post-staging app
   - Configure staging namespace and URL
   - Note: Both apps will initially track same Git repo/branch for Helm chart
   - Different image tags will be set via ArgoCD CLI to deploy different versions
   - Production uses main branch images, staging uses staging branch images

4. Create staging-specific configuration ✅ COMPLETED
   - Create k8s/apps/roast-my-post/values-staging.yaml with staging-specific settings
   - Update k8s/app-manifests/values.yaml to use staging values file for roast-my-post-staging app
   - Staging configuration (domain, environment secret) defined declaratively in Git
   - Image tags set dynamically by CI/CD (same production builds deployed to staging)
   - Uses same resource allocations as production for simplicity

5. Configure Vercel staging environment
   - Apply Terraform changes to add staging environment variables and domain to Vercel project
   - cd terraform/stacks/roast-my-post && terraform apply
   - This configures Vercel to deploy staging branch to staging.roastmypost.org with staging database

6. Deploy via ArgoCD
   - Sync app-of-apps to create staging application: argocd app sync app-of-apps
   - Set image tags for staging: argocd app set roast-my-post-staging --helm-set image.tag=main --helm-set workerImage.tag=main
   - Sync staging app: argocd app sync roast-my-post-staging
   - Image tags can be updated later via ArgoCD CLI or CI/CD automation

7. Verify deployment
   - Check staging app is accessible at https://staging.roastmypost.org
   - Verify database migrations ran successfully (if migration.enabled is true)
   - Check application logs: kubectl -n roast-my-post-staging logs -l app.kubernetes.io/component=web
   - Check worker logs: kubectl -n roast-my-post-staging logs -l app.kubernetes.io/component=worker

NOTES

- Staging uses separate database (roast_my_post_staging) to avoid production interference
- Frontend deployed to Vercel with staging environment variables pointing to staging database
- Backend deployed to Kubernetes with reduced resource allocations (1 replica vs 2)
- Same Helm chart deployed to different namespaces with different configurations via values-staging.yaml
- Image tags can be updated by modifying values-staging.yaml and committing to Git
- SSL certificates automatically provisioned by cert-manager for staging domain
- All configuration is declarative and stored in Git for proper GitOps workflow
