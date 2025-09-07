# Staging Environment Plan

> **⚠️ Work in Progress**

## Overview

This document outlines our staging environment strategy that provides full infrastructure isolation for testing and development. The staging environment is manually controlled via GitHub Actions and kept running most of the time.

## Goals

1. **Full Stack Testing**: Complete isolated environment including separate Kubernetes cluster, databases, and all services
2. **Manual Control**: Simple GitHub Actions workflows to spin up/down the environment
3. **Persistent Environment**: Keep staging running most of the time for continuous development
4. **Infrastructure Isolation**: Completely separate from production infrastructure


## Usage Workflow

### Creating Staging Environment
```bash
# Team lead or developer creates staging environment
1. Go to GitHub Actions → "Staging Environment Control"
2. Run workflow → Select "create"
3. Wait for full infrastructure spin-up 
4. Staging environment available at staging.* domains
5. Deploy apps via ArgoCD as needed
```

### Using Staging Environment
```bash
# Developers use persistent staging for testing
1. Deploy features to staging via ArgoCD
2. Test at staging.roast-my-post.com, staging.squiggle-language.com, etc.
3. Multiple developers can use simultaneously
4. Environment stays up for continuous development
```

### Destroying Staging Environment
```bash
# When staging not needed (e.g., end of sprint, cost savings)
1. Go to GitHub Actions → "Staging Environment Control"
2. Run workflow → Select "destroy"
3. All staging infrastructure torn down
4. Recreate when needed for next development cycle
```

## GitHub Actions Architecture

### Staging Control Workflow
**File**: `.github/workflows/staging-control.yml`

```yaml
name: Staging Environment Control

on:
  workflow_dispatch:
    inputs:
      action:
        description: 'Action to perform'
        required: true
        default: 'create'
        type: choice
        options:
        - create
        - destroy
        - status
      reason:
        description: 'Reason for this action'
        required: false
        default: 'Development testing'

jobs:
  staging-control:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.5.7
        
    - name: Configure 1Password
      uses: 1password/load-secrets-action@v1
      with:
        export-env: true
      env:
        OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
        
    - name: Create Staging Environment
      if: inputs.action == 'create'
      working-directory: terraform/stacks/staging
      run: |
        terraform init
        terraform plan -out=staging.tfplan
        terraform apply staging.tfplan
        echo "Staging environment created successfully"
        echo "Access staging apps at:"
        echo "- staging.roast-my-post.com"
        echo "- staging.squiggle-language.com"
        echo "- staging.getguesstimate.com"
        
    - name: Destroy Staging Environment  
      if: inputs.action == 'destroy'
      working-directory: terraform/stacks/staging
      run: |
        terraform init
        terraform destroy -auto-approve
        echo "Staging environment destroyed successfully"
        
    - name: Check Status
      if: inputs.action == 'status'
      run: |
        # Check DigitalOcean API for staging resources
        echo "Checking staging environment status..."
        # TODO: Implement status check via DO API
```


## Implementation Steps

### Phase 1: Terraform Configuration
1. **Create staging Terraform stack**: Copy production configs to `terraform/stacks/staging/`
2. **Modify for staging**: Update resource names, sizes, and configurations
3. **Set up staging domains**: Configure DNS for staging.* subdomains
4. **Create staging secrets**: Set up 1Password entries with staging prefix

### Phase 2: GitHub Actions
1. **Implement staging control workflow**: Create `.github/workflows/staging-control.yml`
2. **Test manual workflows**: Verify create/destroy operations work
3. **Set up ArgoCD staging apps**: Configure staging application deployments
4. **Document usage**: Update team documentation for staging workflow


## Security and Access Control

### Environment Isolation
- **Separate cluster**: Complete network isolation from production
- **Separate databases**: No shared data with production
- **Staging secrets**: Dedicated 1Password entries with staging prefix
- **Domain isolation**: staging.* subdomains with separate SSL certificates
