# 1Password secrets references
data "onepassword_item" "server_api_key" {
  vault = module.providers.op_vault
  title = "Longtermwiki LONGTERMWIKI_SERVER_API_KEY"
}

data "onepassword_item" "anthropic_api_key" {
  vault = module.providers.op_vault
  title = "Longtermwiki ANTHROPIC_API_KEY"
}

data "onepassword_item" "discord_token" {
  vault = module.providers.op_vault
  title = "Longtermwiki DISCORD_TOKEN"
}

# Create namespace
resource "kubernetes_namespace" "longtermwiki" {
  metadata {
    name = local.k8s_namespace
  }
}

# Kubernetes secret for wiki-server
resource "kubernetes_secret" "longtermwiki_env" {
  metadata {
    namespace = local.k8s_namespace
    name      = "longtermwiki-env"
  }

  data = {
    DATABASE_URL                = module.database.direct_url
    LONGTERMWIKI_SERVER_API_KEY = data.onepassword_item.server_api_key.password
  }

  depends_on = [kubernetes_namespace.longtermwiki]
}

# Kubernetes secret for discord bot
resource "kubernetes_secret" "discord_bot_env" {
  metadata {
    namespace = local.k8s_namespace
    name      = "longtermwiki-discord-bot-env"
  }

  data = {
    ANTHROPIC_API_KEY = data.onepassword_item.anthropic_api_key.password
    DISCORD_TOKEN     = data.onepassword_item.discord_token.password
    WIKI_BASE_URL     = "https://www.longtermwiki.com"
  }

  depends_on = [kubernetes_namespace.longtermwiki]
}
