locals {
  # trick from https://github.com/hashicorp/terraform/issues/25609#issuecomment-1057614400
  validate_www_with_subdomain = (var.subdomain != null && var.www) ? tobool("subdomain and www can't be set at the same time") : true

  primary_domain    = var.www ? "www.${var.domain}" : var.domain
  redirected_domain = var.redirect == "" ? local.primary_domain : var.redirect
}

# Main can point to www.domain.com or to domain.com, depending on whether `www` flag is set.
# Note that if `redirect` is also set, this won't matter, because both domain.com and www.domain.com will point to the same external domain.
resource "vercel_project_domain" "main" {
  project_id = var.project_id

  domain = local.primary_domain

  redirect             = var.redirect == "" ? null : local.redirected_domain
  redirect_status_code = var.redirect == "" ? null : 308
}

resource "vercel_project_domain" "www_redirect" {
  # If using a subdomain, don't create a redirect.
  count = var.subdomain == null ? 1 : 0

  project_id = var.project_id

  # Inverted compared to `main` domain
  # So if www is set, we'll redirect from domain.com to www.domain.com, and if not, from www.domain.com to domain.com.
  domain = var.www ? var.domain : "www.${var.domain}"

  redirect             = local.redirected_domain
  redirect_status_code = 308
}
