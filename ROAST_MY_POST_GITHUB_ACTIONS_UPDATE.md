# GitHub Actions Update Required for roast-my-post

## Context
The roast-my-post deployment has been updated to work like Squiggle's automated deployment. Two changes have been made in the ops repo:

1. **Enabled automated sync** - Removed `automated: null` from app-manifests/values.yaml
2. **Prepared for immutable tags** - Updated Helm values to accept SHA-based tags via CI/CD

## Required GitHub Actions Changes

Add the following to `.github/workflows/docker.yml` in the roast-my-post repository:

### 1. Add ArgoCD server environment variable
```yaml
env:
  ARGOCD_SERVER: argo.k8s.quantifieduncertainty.org
  ARGOCD_APP: roast-my-post
```

### 2. Add new job to update ArgoCD after building images
```yaml
  update-argocd:
    needs: build-and-push  # This waits for both matrix builds to complete
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - name: Update ArgoCD image tags
        env:
          ARGOCD_SERVER: ${{ env.ARGOCD_SERVER }}
          ARGOCD_AUTH_TOKEN: ${{ secrets.ARGOCD_AUTH_TOKEN }}
        run: |
          set -e  # Exit on any error
          
          # Download ArgoCD CLI
          echo "Downloading ArgoCD CLI..."
          curl -sSL -o /usr/local/bin/argocd https://${ARGOCD_SERVER}/download/argocd-linux-amd64 || {
            echo "Failed to download ArgoCD CLI"
            exit 1
          }
          chmod +x /usr/local/bin/argocd
          
          # ArgoCD CLI uses ARGOCD_AUTH_TOKEN env var automatically, but needs --server flag
          echo "Updating image tags to sha-${{ github.sha }}..."
          /usr/local/bin/argocd app set ${ARGOCD_APP} \
            --server ${ARGOCD_SERVER} \
            --helm-set image.tag=sha-${{ github.sha }} \
            --helm-set workerImage.tag=sha-${{ github.sha }}
          
          # Trigger sync (even though auto-sync is enabled, this ensures immediate deployment)
          echo "Triggering application sync..."
          /usr/local/bin/argocd app sync ${ARGOCD_APP} \
            --server ${ARGOCD_SERVER}
          
          # Wait for sync to complete and verify health
          echo "Waiting for deployment to complete (timeout: 5 minutes)..."
          /usr/local/bin/argocd app wait ${ARGOCD_APP} \
            --server ${ARGOCD_SERVER} \
            --timeout 300 \
            --health \
            --sync
          
          # Get final status for the logs
          echo "Deployment completed. Final status:"
          /usr/local/bin/argocd app get ${ARGOCD_APP} \
            --server ${ARGOCD_SERVER} \
            --output json | \
            jq -r '"Sync: " + .status.sync.status + ", Health: " + .status.health.status'
```

### 3. Update Docker build to use full SHA tags
The current workflow uses `type=sha` which generates short SHA tags. For consistency with the ArgoCD update, modify to use full SHA:

```yaml
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix=sha-,format=long  # Use full SHA, not short
```

**Important**: The `format=long` ensures the full commit SHA is used, matching what we set in ArgoCD (`sha-${{ github.sha }}`)

### 4. Add GitHub Secret
You need to add `ARGOCD_AUTH_TOKEN` as a repository secret. This token can be obtained from the ArgoCD UI or by an admin who has access to the ArgoCD server.

## Prerequisites - IMPORTANT!

**Before the GitHub Actions changes will work, you need to:**

1. **Sync the app-of-apps application** to apply the automated sync setting:
   ```bash
   # Via ArgoCD UI: Navigate to app-of-apps and click Sync
   # OR via CLI (requires login):
   argocd login argo.k8s.quantifieduncertainty.org
   argocd app sync app-of-apps
   ```
   This is necessary because we removed `automated: null` from the roast-my-post configuration, but app-of-apps needs to be synced to apply this change.

2. **Verify automated sync is enabled**:
   ```bash
   argocd app get roast-my-post -o json | jq '.spec.syncPolicy.automated'
   ```
   Should return `{}` (not null)

## How It Works Now

1. Push to main branch triggers GitHub Actions
2. Docker images are built and tagged with `sha-<commit-hash>`
3. Images are pushed to ghcr.io
4. GitHub Actions updates ArgoCD: `argocd app set roast-my-post --helm-set image.tag=sha-xxxxx`
5. ArgoCD detects the manifest change (new SHA in values)
6. ArgoCD automatically syncs (because automated sync is now enabled)
7. Kubernetes pulls the new images and updates the pods

## Benefits

- **Automatic deployments** - No manual intervention needed
- **Immutable tags** - Each deployment is traceable to exact commit
- **Reliable updates** - ArgoCD always knows when images change
- **Rollback capability** - Easy to revert to previous SHA

## Alternative: Comprehensive Deployment Verification

For even better deployment verification, you can add a separate verification step:

```yaml
      - name: Verify deployment completed
        env:
          ARGOCD_AUTH_TOKEN: ${{ secrets.ARGOCD_AUTH_TOKEN }}
        run: |
          # Function to check if pods are running the new image
          verify_deployment() {
            local expected_tag="sha-${{ github.sha }}"
            
            # Get app resources (server flag required, auth token from env)
            /usr/local/bin/argocd app resources ${ARGOCD_APP} \
              --server ${ARGOCD_SERVER} \
              --kind Deployment \
              --output json | jq -r '.[] | 
                select(.kind == "Deployment") | 
                .name + ": " + .status'
            
            # Check if deployments are using the correct image
            echo "Checking image tags..."
            /usr/local/bin/argocd app manifests ${ARGOCD_APP} \
              --server ${ARGOCD_SERVER} \
              --revision HEAD | grep -E "image:.*${expected_tag}" || {
                echo "ERROR: Deployments not using expected tag ${expected_tag}"
                exit 1
              }
            
            echo "✅ Deployment verification successful!"
          }
          
          verify_deployment
```

## What This Provides

The enhanced workflow will:
1. **Update** the image tags in ArgoCD
2. **Trigger** an immediate sync (not waiting for auto-sync)
3. **Wait** for the sync to complete (with 5-minute timeout)
4. **Verify** both sync status and health status
5. **Fail** the GitHub Actions job if deployment fails

This means:
- ✅ Green check in GitHub = deployment succeeded in Kubernetes
- ❌ Red X in GitHub = deployment failed (sync failed, unhealthy, or timeout)
- 📊 Full visibility in GitHub Actions logs of what happened

## Important Notes & Potential Issues

### Job Dependencies
The `update-argocd` job has `needs: build-and-push` which waits for the matrix strategy job to complete (both main and worker images). This matches the current docker.yml structure.

### SHA Tag Format
Both images must be tagged with the same format. The workflow needs to generate tags like `sha-<full-sha>` (not shortened). This requires adding `format=long` to the metadata action's SHA tag configuration. Without this, the default generates short SHAs which won't match the `${{ github.sha }}` value used in the ArgoCD update.

### Environment Variables
The ArgoCD CLI automatically uses `ARGOCD_AUTH_TOKEN` from the environment variable (no need for --auth-token flag), but **requires the --server flag** to be explicitly passed. This is why we use `--server ${ARGOCD_SERVER}` in all commands.

### Error Handling
- The script uses `set -e` to exit on any error
- The curl command has explicit error handling
- The wait command will exit with non-zero if deployment fails

### Timeout Considerations
- 300 seconds (5 minutes) should be sufficient for most deployments
- Adjust if your application takes longer to become healthy
- Consider that initial deployments might take longer than updates

## Testing

After implementing these changes:
1. Push a commit to main branch
2. Watch GitHub Actions - it will show:
   - Building images ✅
   - Pushing to registry ✅
   - Updating ArgoCD ✅
   - Waiting for deployment ⏳
   - Deployment healthy ✅ (or ❌ if failed)
3. Check ArgoCD UI - should show the new SHA tag
4. Verify pods are running the new image: `kubectl get pods -n roast-my-post -o jsonpath='{.items[*].spec.containers[*].image}'`

## Troubleshooting

If the deployment fails:
1. Check the ArgoCD UI for sync errors
2. Check pod logs: `kubectl logs -n roast-my-post -l app.kubernetes.io/name=roast-my-post`
3. Verify the image was pushed: Check ghcr.io package page
4. Ensure the ARGOCD_AUTH_TOKEN secret is set correctly in GitHub