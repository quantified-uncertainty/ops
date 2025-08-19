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
    needs: [build-main-image, build-worker-image]
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - name: Update ArgoCD image tags
        env:
          ARGOCD_AUTH_TOKEN: ${{ secrets.ARGOCD_AUTH_TOKEN }}
        run: |
          # Download ArgoCD CLI
          curl -sSL -o /usr/local/bin/argocd https://${ARGOCD_SERVER}/download/argocd-linux-amd64
          chmod +x /usr/local/bin/argocd
          
          # Update both image tags with the commit SHA
          /usr/local/bin/argocd app set ${ARGOCD_APP} \
            --server ${ARGOCD_SERVER} \
            --auth-token ${ARGOCD_AUTH_TOKEN} \
            --helm-set image.tag=sha-${{ github.sha }} \
            --helm-set workerImage.tag=sha-${{ github.sha }}
          
          # Optionally trigger sync (remove if you want to rely on auto-sync)
          /usr/local/bin/argocd app sync ${ARGOCD_APP} \
            --server ${ARGOCD_SERVER} \
            --auth-token ${ARGOCD_AUTH_TOKEN}
```

### 3. Update Docker build to use SHA tags
Modify the metadata-action step to generate SHA-based tags:

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
            type=sha,prefix=sha-,format=long
```

### 4. Add GitHub Secret
You need to add `ARGOCD_AUTH_TOKEN` as a repository secret. This token can be obtained from the ArgoCD UI or by an admin who has access to the ArgoCD server.

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

## Testing

After implementing these changes:
1. Push a commit to main branch
2. Watch GitHub Actions complete
3. Check ArgoCD UI - should show the new SHA tag
4. Verify pods are running the new image: `kubectl get pods -n roast-my-post -o jsonpath='{.items[*].spec.containers[*].image}'`