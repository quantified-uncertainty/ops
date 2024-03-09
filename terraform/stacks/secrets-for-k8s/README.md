This stack solves a small internal task: how do we depend on 1Password items in Kubernetes manifests?

We could use [External Secrets Operator](https://external-secrets.io) or an official [1Password Kubernetes Operator](https://developer.1password.com/docs/k8s/k8s-operator), but both of these would require setting up a connect server.

So, instead, we just sync up 1Password items to Kubernetes secrets.

This approach has its downsides (item updates are not synced up automatically), but it's good enough for now.

**Important**: this stack relies on your `~/.kube/config` being configured, and assumes that QURI k8s cluster is configured as a `default` context. If your context is named differently, you'll need to set `KUBE_CTX` env var.
