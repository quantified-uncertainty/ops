# Roast My Post Deployment

This directory contains the Terraform configuration for deploying Roast My Post infrastructure.

## Overview

Roast My Post is an AI-powered document review and feedback platform that uses:
- Next.js 15 for the web application
- PostgreSQL for data storage
- Background workers for async job processing
- AI integrations (Anthropic, OpenRouter)

## Architecture

### Infrastructure Components

1. **Database**: DigitalOcean PostgreSQL cluster (v16)
2. **Frontend**: Vercel deployment for Next.js app
3. **Backend**: Kubernetes deployment with:
   - Web service (3 replicas)
   - Worker service (2 replicas)
   - Auto-scaling based on CPU/memory usage

### Deployment Flow

1. **Terraform** provisions:
   - PostgreSQL database cluster
   - Database user and permissions
   - Kubernetes secrets from 1Password
   - Vercel project configuration
   - Domain configuration

2. **Kubernetes** (via ArgoCD) deploys:
   - Database migration job (runs Prisma migrations)
   - Web deployment (Next.js app)
   - Worker deployment (job processor)
   - Ingress with automatic SSL

## Prerequisites

1. **1Password Secrets** - Create the following items in the "Infra" vault:
   - `Roast My Post AUTH_SECRET` - 32-byte secret for NextAuth
   - `Roast My Post ANTHROPIC_API_KEY` - Anthropic API key
   - `Roast My Post OPENROUTER_API_KEY` - OpenRouter API key
   - `Roast My Post SENDGRID_KEY` - SendGrid API key
   - `Roast My Post AUTH_RESEND_KEY` - Resend API key
   - `Roast My Post MCP_USER_API_KEY` - MCP server API key

2. **Domain** - Ensure `roastmypost.org` is available or update `locals.domain` in `main.tf`

3. **Harbor Registry** - Ensure the Docker image is pushed to:
   ```
   harbor.k8s.quantifieduncertainty.org/main/roast-my-post:TAG
   ```

## Deployment Steps

### 1. Deploy Infrastructure with Terraform

```bash
cd terraform/stacks/roast-my-post
terraform init
terraform plan
terraform apply
```

This will create:
- PostgreSQL database cluster
- Database user and connection pool
- Kubernetes namespace and secrets
- Vercel project and domain configuration

### 2. Build and Push Docker Image

In the roast-my-post repository:

```bash
docker build -t harbor.k8s.quantifieduncertainty.org/main/roast-my-post:latest .
docker push harbor.k8s.quantifieduncertainty.org/main/roast-my-post:latest
```

### 3. Deploy to Kubernetes

The application is configured in ArgoCD and will be deployed automatically after syncing:

```bash
# Check ArgoCD status
argocd app get roast-my-post

# Sync if needed
argocd app sync roast-my-post
```

### 4. Verify Deployment

1. Check pods are running:
   ```bash
   kubectl -n roast-my-post get pods
   ```

2. Check ingress:
   ```bash
   kubectl -n roast-my-post get ingress
   ```

3. Access the application at https://roastmypost.org

## Configuration

### Environment Variables

All environment variables are stored in Kubernetes secret `roast-my-post-env`:
- Database connection strings
- Authentication secrets
- API keys for AI services
- Email service credentials

### Scaling

The application auto-scales based on:
- **Web**: 3-10 replicas (70% CPU, 80% memory)
- **Worker**: 2-5 replicas (70% CPU, 80% memory)

### Database

- **Size**: db-s-1vcpu-1gb (can be scaled via Terraform)
- **Storage**: 30GB
- **Connection Pool**: 20 connections
- **Backups**: Managed by DigitalOcean

## Monitoring

- Application logs: Available in Loki
- Metrics: Prometheus/Grafana dashboards
- Database metrics: DigitalOcean dashboard

## Troubleshooting

### Database Connection Issues
1. Check the Kubernetes secret contains correct URLs
2. Verify database firewall rules allow K8s cluster
3. Check connection pool settings

### Migration Failures
1. Check migration job logs: `kubectl -n roast-my-post logs -l app.kubernetes.io/component=migration`
2. Ensure database permissions are correct
3. Verify Prisma schema is valid

### Application Crashes
1. Check pod logs: `kubectl -n roast-my-post logs -l app.kubernetes.io/component=web`
2. Verify all required environment variables are set
3. Check resource limits are adequate

## Maintenance

### Database Migrations
Migrations run automatically on deployment. For manual migrations:

```bash
kubectl -n roast-my-post run migration --image=harbor.k8s.quantifieduncertainty.org/main/roast-my-post:latest --rm -it -- npm run db:deploy
```

### Updating Secrets
1. Update secret in 1Password
2. Run `terraform apply` to update Kubernetes secret
3. Restart deployments: `kubectl -n roast-my-post rollout restart deployment`

### Scaling Database
Update `size` in `db.tf` and run `terraform apply`. Note: This may cause brief downtime.