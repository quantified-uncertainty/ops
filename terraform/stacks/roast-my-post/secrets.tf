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

# Firecrawl API key for article importing
data "onepassword_item" "firecrawl_key" {
  vault = module.providers.op_vault
  title = "Roast My Post FIRECRAWL_KEY"
}

# Helicone API key for API monitoring and caching
data "onepassword_item" "helicone_api_key" {
  vault = module.providers.op_vault
  title = "Roast My Post HELICONE_API_KEY"
}

# Diffbot API key
data "onepassword_item" "diffbot_key" {
  vault = module.providers.op_vault
  title = "Roast My Post DIFFBOT_KEY"
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
    
    # Article import services
    FIRECRAWL_KEY = data.onepassword_item.firecrawl_key.password
    
    # Email services
    SENDGRID_KEY    = data.onepassword_item.sendgrid_key.password
    EMAIL_FROM      = "noreply@${local.domain}"
    AUTH_RESEND_KEY = data.onepassword_item.auth_resend_key.password
    
    # MCP Server configuration (optional)
    ROAST_MY_POST_MCP_USER_API_KEY = data.onepassword_item.mcp_user_api_key.password
    ROAST_MY_POST_MCP_DATABASE_URL = module.database.bouncer_url
    ROAST_MY_POST_MCP_API_BASE_URL = "https://${local.domain}"
    
    # Helicone configuration
    HELICONE_API_KEY                 = data.onepassword_item.helicone_api_key.password
    HELICONE_CACHE_ENABLED           = "true"
    HELICONE_CACHE_MAX_AGE           = "7200"           # 2 hours
    HELICONE_CACHE_BUCKET_MAX_SIZE   = "20"             # Max allowed by Helicone
    HELICONE_SESSIONS_ENABLED        = "true"
    HELICONE_JOB_SESSIONS_ENABLED    = "true"
    HELICONE_DETAILED_PATHS_ENABLED  = "true"
    HELICONE_CUSTOM_METADATA_ENABLED = "true"
    
    # Diffbot configuration
    DIFFBOT_KEY = data.onepassword_item.diffbot_key.password
    
    # Ephemeral Experiments Configuration
    CLEANUP_INTERVAL_MINUTES     = "60"
    CLEANUP_DRY_RUN              = "false"
    MAX_EXPERIMENTS_PER_USER     = "50"
    DEFAULT_EXPERIMENT_EXPIRY_DAYS = "7"
    MAX_EXPERIMENT_EXPIRY_DAYS   = "30"
  }
}

# Create namespace if it doesn't exist
resource "kubernetes_namespace" "roast_my_post" {
  metadata {
    name = local.k8s_namespace
  }
}

# Create staging namespace
resource "kubernetes_namespace" "roast_my_post_staging" {
  metadata {
    name = "roast-my-post-staging"
  }
}

# Kubernetes secret for staging environment
resource "kubernetes_secret" "roast_my_post_staging_env" {
  metadata {
    namespace = "roast-my-post-staging"
    name      = "roast-my-post-staging-env"
  }

  data = {
    # Database URLs - pointing to staging database
    DATABASE_URL     = module.staging_database.bouncer_url
    PRISMA_URL       = module.staging_database.direct_url
    DATABASE_CA_CERT = module.staging_database.ca_cert
    
    # Authentication
    AUTH_SECRET   = data.onepassword_item.auth_secret.password
    NEXTAUTH_URL  = "https://staging.${local.domain}"
    
    # AI/LLM APIs
    ANTHROPIC_API_KEY  = data.onepassword_item.anthropic_api_key.password
    OPENROUTER_API_KEY = data.onepassword_item.openrouter_api_key.password
    
    # Article import services
    FIRECRAWL_KEY = data.onepassword_item.firecrawl_key.password
    
    # Email services
    SENDGRID_KEY    = data.onepassword_item.sendgrid_key.password
    EMAIL_FROM      = "noreply@${local.domain}"
    AUTH_RESEND_KEY = data.onepassword_item.auth_resend_key.password
    
    # MCP Server configuration (optional)
    ROAST_MY_POST_MCP_USER_API_KEY = data.onepassword_item.mcp_user_api_key.password
    ROAST_MY_POST_MCP_DATABASE_URL = module.staging_database.bouncer_url
    ROAST_MY_POST_MCP_API_BASE_URL = "https://staging.${local.domain}"
    
    # Helicone configuration
    HELICONE_API_KEY                 = data.onepassword_item.helicone_api_key.password
    HELICONE_CACHE_ENABLED           = "true"
    HELICONE_CACHE_MAX_AGE           = "7200"           # 2 hours
    HELICONE_CACHE_BUCKET_MAX_SIZE   = "20"             # Max allowed by Helicone
    HELICONE_SESSIONS_ENABLED        = "true"
    HELICONE_JOB_SESSIONS_ENABLED    = "true"
    HELICONE_DETAILED_PATHS_ENABLED  = "true"
    HELICONE_CUSTOM_METADATA_ENABLED = "true"
    
    # Diffbot configuration
    DIFFBOT_KEY = data.onepassword_item.diffbot_key.password
    
    # Ephemeral Experiments Configuration
    CLEANUP_INTERVAL_MINUTES     = "60"
    CLEANUP_DRY_RUN              = "false"
    MAX_EXPERIMENTS_PER_USER     = "50"
    DEFAULT_EXPERIMENT_EXPIRY_DAYS = "7"
    MAX_EXPERIMENT_EXPIRY_DAYS   = "30"
  }

  depends_on = [kubernetes_namespace.roast_my_post_staging]
}
