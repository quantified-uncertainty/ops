# 1Password secrets references
data "onepassword_item" "auth_secret" {
  vault = module.providers.op_vault
  title = "Roast My Post AUTH_SECRET"
}

data "onepassword_item" "anthropic_api_key" {
  vault = module.providers.op_vault
  title = "Roast My Post ANTHROPIC_API_KEY"
}

data "onepassword_item" "openrouter_api_key" {
  vault = module.providers.op_vault
  title = "Roast My Post OPENROUTER_API_KEY"
}

data "onepassword_item" "sendgrid_key" {
  vault = module.providers.op_vault
  title = "Roast My Post SENDGRID_KEY"
}

data "onepassword_item" "auth_resend_key" {
  vault = module.providers.op_vault
  title = "Roast My Post AUTH_RESEND_KEY"
}

# MCP Server API keys (optional)
data "onepassword_item" "mcp_user_api_key" {
  vault = module.providers.op_vault
  title = "Roast My Post MCP_USER_API_KEY"
}

# Kubernetes secret with all environment variables
resource "kubernetes_secret" "roast_my_post_env" {
  metadata {
    namespace = local.k8s_namespace
    name      = "roast-my-post-env"
  }

  data = {
    # Database URLs
    DATABASE_URL = module.database.bouncer_url
    PRISMA_URL   = module.database.direct_url
    
    # Authentication
    AUTH_SECRET   = data.onepassword_item.auth_secret.password
    NEXTAUTH_URL  = "https://${local.domain}"
    
    # AI/LLM APIs
    ANTHROPIC_API_KEY  = data.onepassword_item.anthropic_api_key.password
    OPENROUTER_API_KEY = data.onepassword_item.openrouter_api_key.password
    
    # Email services
    SENDGRID_KEY    = data.onepassword_item.sendgrid_key.password
    EMAIL_FROM      = "noreply@${local.domain}"
    AUTH_RESEND_KEY = data.onepassword_item.auth_resend_key.password
    
    # MCP Server configuration (optional)
    ROAST_MY_POST_MCP_USER_API_KEY = data.onepassword_item.mcp_user_api_key.password
    ROAST_MY_POST_MCP_DATABASE_URL = module.database.bouncer_url
    ROAST_MY_POST_MCP_API_BASE_URL = "https://${local.domain}"
  }
}

# Create namespace if it doesn't exist
resource "kubernetes_namespace" "roast_my_post" {
  metadata {
    name = local.k8s_namespace
  }
}