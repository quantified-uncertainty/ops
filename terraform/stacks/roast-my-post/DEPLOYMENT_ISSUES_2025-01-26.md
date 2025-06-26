# Roast My Post Deployment Issues - 2025-01-26

## Initial Deployment Attempt

### Prerequisites Completed
- [x] 1Password secrets created:
  - AUTH_SECRET
  - ANTHROPIC_API_KEY  
  - OPENROUTER_API_KEY
  - SENDGRID_KEY
  - AUTH_RESEND_KEY (placeholder)
  - MCP_USER_API_KEY (placeholder)
  - GitHub token for ops (placeholder)
- [x] Domain nameservers changed to DigitalOcean:
  - ns1.digitalocean.com
  - ns2.digitalocean.com
  - ns3.digitalocean.com
- [x] Deleted existing Vercel project to allow Terraform to manage it

### Known Issues Encountered

1. **1Password Account Mismatch**
   - Issue: QURI's 1Password uses `my.1password.com` instead of `team-quri.1password.com`
   - Fix: Updated `terraform/modules/providers/outputs.tf` to use correct account

2. **Database Module Output Names**
   - Issue: Module outputs were `direct_url` and `bouncer_url`, not `url` and `url_prisma`
   - Fix: Updated all references in the terraform stack

3. **Interrupted Terraform Apply**
   - Issue: First terraform apply was interrupted during database creation
   - Result: Some resources were created but not tracked in state
   - Current status: Resources exist but Terraform doesn't know about them

### Current State

Resources that exist but are not in Terraform state:
- Kubernetes namespace: `roast-my-post`
- DigitalOcean domain: `roastmypost.org`
- DigitalOcean project: `Roast My Post`
- DigitalOcean database cluster: `roast-my-post` (possibly)

### Next Steps Options

#### Option 1: Import Existing Resources (Recommended)
Import the resources into Terraform state so it knows about them:
```bash
terraform import kubernetes_namespace.roast_my_post roast-my-post
terraform import module.domain.digitalocean_domain.main[0] roastmypost.org
# Find and import project and database IDs
```

#### Option 2: Clean Up and Retry
Delete the resources manually and let Terraform create them fresh:
```bash
kubectl delete namespace roast-my-post
# Delete domain, project, and database in DigitalOcean UI
terraform apply
```

#### Option 3: Wait and Debug
Check if resources are partially created and may self-heal:
```bash
terraform plan  # See what Terraform thinks needs to be created
terraform refresh  # Update state from reality
```

### Root Cause of Interruption
- Database creation takes 5-15 minutes
- Command timeout was set to 2 minutes
- Fix: Use longer timeout (10+ minutes) for terraform apply

### Commands Run

```bash
# Initial setup
cd terraform/stacks/roast-my-post
terraform init
terraform plan -out=tfplan
terraform apply tfplan  # INTERRUPTED after 2 minutes (timeout too short)

# State was locked, had to unlock
terraform force-unlock 1c061b99-939f-dc64-2880-270b04ef8358

# Attempted to reapply
terraform apply -auto-approve  # FAILED - resources already exist
```

### Costs Incurred
- Database cluster may be running (~$15-20/month) if it was created

### Security Notes
- All API keys are stored in 1Password
- Database will only be accessible from Kubernetes cluster
- No secrets are stored in code or state files