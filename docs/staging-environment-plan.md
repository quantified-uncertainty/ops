# On-Demand Staging Environment Plan

> **⚠️ Work in Progress**:.

## Overview

This document outlines our on-demand staging environment strategy that provides full infrastructure isolation while maintaining cost efficiency through automatic spin-up/tear-down workflows.

## Goals

1. **Cost Efficiency**: Pay only for staging resources when actively used
2. **Full Stack Testing**: Complete isolated environment including separate Kubernetes cluster, databases, and all services
3. **Flexible Usage**: Support both manual development testing and automated CI/CD workflows
4. **Smart Automation**: Reuse existing staging environments when possible, create when needed
5. **Clean State**: Every staging deployment starts with fresh infrastructure

## Core Approach

### On-Demand Infrastructure
- **Spin-up time**: NN-NN minutes for full cluster + databases
- **Auto-destroy**: Always tear down after use

### Two Usage Patterns

#### 1. Manual Development Testing
- Developer manually triggers staging environment creation
- Use for feature development, debugging, manual testing
- Developer controls lifecycle (create/destroy)

#### 2. Automated CI/CD Testing  
- Triggered by pushes to `staging` branch
- Smart detection: reuse existing staging or create new
- Automated app deployment + integration tests
- Human approval gate before production deployment

## Workflow Examples

### Scenario 1: Manual Development Testing
```bash
# Developer wants to test roast-my-post feature
1. GitHub Actions → "Staging Environment Control" → Run workflow → Create
2. Wait for full infrastructure spin-up
3. Deploy feature via ArgoCD to staging.roast-my-post.com
4. Test and debug as needed
5. When finished: GitHub Actions → "Staging Environment Control" → Destroy
```

### Scenario 2: Automated CI/CD Testing
```bash
# Developer pushes app changes to staging branch
1. git push origin staging
2. GitHub detects changed apps (e.g., roast-my-post)
3. Checks if staging environment exists:
   - If exists: Deploy apps directly
   - If not: Create staging environment first
4. Deploy changed apps to staging
5. Run integration tests for changed apps
6. Create approval issue with test results and staging URLs
7. Human reviews staging.roast-my-post.com and approves/rejects
8. If approved: Auto-merge to main → trigger prod deployment
9. Always: Destroy staging environment after decision
```

### Scenario 3: Collaborative Development
```bash
# Multiple developers using shared staging
1. Developer A creates staging environment manually
2. Developer B pushes to staging branch
3. System detects existing staging, deploys B's changes
4. Both developers can test simultaneously
5. Either developer can trigger destruction when done
```

## GitHub Actions Architecture

### 1. Manual Staging Control Workflow
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
        description: 'Reason for staging environment'
        required: false
        default: 'Manual testing'

jobs:
  staging-control:
    runs-on: ubuntu-latest
    steps:
    - name: Create Staging Environment
      if: inputs.action == 'create'
      run: |
        # Deploy full Terraform infrastructure
        # Set environment state tracking
        
    - name: Destroy Staging Environment  
      if: inputs.action == 'destroy'
      run: |
        # Tear down all infrastructure
        # Clear environment state
        
    - name: Check Status
      if: inputs.action == 'status'
      run: |
        # Report current staging environment status
```

### 2. Smart Staging Deployment Workflow
**File**: `.github/workflows/staging-deploy.yml`

```yaml
name: Staging App Deployment

on:
  push:
    branches: [staging]

jobs:
  analyze-changes:
    runs-on: ubuntu-latest
    outputs:
      staging-exists: ${{ steps.check.outputs.exists }}
      changed-apps: ${{ steps.changes.outputs.apps }}
    steps:
    - name: Check staging environment status
      id: check
      run: |
        # Check DigitalOcean API for staging cluster
        # Output: exists=true/false
        
    - name: Detect changed applications
      id: changes
      run: |
        # Analyze git diff to determine changed apps
        # Output: apps=["roast-my-post","guesstimate"]

  create-staging-if-needed:
    needs: analyze-changes
    if: needs.analyze-changes.outputs.staging-exists == 'false'
    runs-on: ubuntu-latest
    steps:
    - name: Create staging infrastructure
      run: |
        # Deploy full Terraform stack
        # Wait for cluster readiness

  deploy-and-test:
    needs: [analyze-changes, create-staging-if-needed]
    if: always() && !failure()
    runs-on: ubuntu-latest
    strategy:
      matrix:
        app: ${{ fromJson(needs.analyze-changes.outputs.changed-apps) }}
    steps:
    - name: Deploy app to staging
      run: |
        # Deploy specific app via ArgoCD
        argocd app sync staging-${{ matrix.app }}
        
    - name: Run integration tests
      run: |
        # Run app-specific integration tests
        npm run test:integration --prefix=apps/${{ matrix.app }}

  await-approval:
    needs: deploy-and-test
    runs-on: ubuntu-latest
    steps:
    - name: Create approval request
      run: |
        # Create GitHub issue with:
        # - Test results summary
        # - Links to staging URLs
        # - Approve/Reject buttons
        
    - name: Wait for human decision
      uses: trstringer/manual-approval@v1
      with:
        secret: ${{ github.TOKEN }}
        approvers: team-leads
        
  finalize:
    needs: await-approval
    runs-on: ubuntu-latest
    steps:
    - name: Merge to main if approved
      if: needs.await-approval.outputs.approved == 'true'
      run: |
        # Create and auto-merge PR to main
        
    - name: Always destroy staging
      run: |
        # Tear down staging infrastructure
        # Whether approved or rejected
```


## Implementation Steps

### Phase 1: Repository Setup
1. **Create staging Terraform configs**: Copy and modify production configs
2. **Set up staging domains**: Configure DNS for staging subdomains
3. **Create staging secrets**: Set up 1Password entries for staging
4. **Test manual deployment**: Verify staging infrastructure works

### Phase 2: GitHub Actions
1. **Implement manual control workflow**: `staging-control.yml`
2. **Create smart deployment workflow**: `staging-deploy.yml`
3. **Add environment state tracking**: GitHub variables + DO API checks
4. **Test automation**: Verify workflows work end-to-end


## Security and Access Control

### Environment Isolation
- **Separate cluster**: Complete network isolation from production
- **Separate databases**: No shared data with production
- **Staging secrets**: Dedicated 1Password entries with staging prefix
- **Domain isolation**: staging.* subdomains with separate SSL certificates
