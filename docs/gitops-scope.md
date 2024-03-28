A significant part of QURI infrastructure is now under Terraform or Kubernetes control, and managed with GitOps methodology, where the state of configs in this repository should always match the state of existing resources in the cloud.

It can be hard to tell which parts are managed, and which should be configured through web UIs.

But the parts that _are_ managed should never be configured with web UIs; otherwise the things will get out of sync.

So this document describes the current boundary between "GitOps" and "ClickOps".

Written by @berekuk.

# By service

## Vercel

**Under Terraform control. Don't configure things through UI.**

Use `vercel_project` resources and our custom `modules/vercel-domain` to create new projects.

There might be some legacy projects which are not described in Terraform yet; we'll import them later.

## DigitalOcean

**Under Terraform control. Don't configure things through UI.**

## Heroku

**Partially under Terraform control; legacy service.**

We plan to migrate from Heroku soon, so bringing it in Terraform is not important, but I imported some Guesstimate things to smoothen the migration.

## NameCheap

**Not under Terraform control, but please delegate nameservers to DigitalOcean and then configure DNS there through Terraform.**

NameCheap does have a Terraform provider, but its API is locked down by default and you have to whitelist each new IP manually. See also: `tools/check-namecheap` scripts, which give you the ability to see which nameservers we've delegated.

## AWS

**Not under Terraform control. We don't use AWS.**

Except for S3 bucket containing Terraform state, which is provisioned by `terraform/bootstrap`.

## GitHub

**Git repositories are partially configured by Terraform.**

In particular, we have Terraform resources for GitHub action secrets and environments.

Repository settings themselves are not in Terraform yet, but maybe they should be.

## Algolia

**Not under Terraform control, but it should be.**

Might be difficult though: I think Algolia API keys are per-application, and also there's no official Terraform provider, though community-tier providers seem decent.

## Auth0

**Under Terraform control for Guesstimate, but not for Foretold.**

We should use Terraform for Auth0 from now on, though we don't plan to use Auth0 much in the future.

## Kubernetes

**Bootstrapped by Terraform. Then managed by Argo CD.**

## Metabase (our self-hosted instance)

**Users and database configs are not managed by Terraform yet. Probably should be.**

There are a few community providers to do that, and it'd be neat to wire database credentials from Kubernetes to Metabase.
