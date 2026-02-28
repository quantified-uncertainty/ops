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

data "onepassword_item" "github_app_private_key" {
  vault = module.providers.op_vault
  title = "QURI Integrations GitHub App Private Key"
}

data "onepassword_item" "groundskeeper_discord_webhook" {
  vault = module.providers.op_vault
  title = "Longtermwiki Groundskeeper DISCORD_WEBHOOK_URL"
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

# Kubernetes secret for groundskeeper
resource "kubernetes_secret" "groundskeeper_env" {
  metadata {
    namespace = local.k8s_namespace
    name      = "longtermwiki-groundskeeper-env"
  }

  data = {
    ANTHROPIC_API_KEY      = data.onepassword_item.anthropic_api_key.password
    GITHUB_APP_ID          = "856482"
    GITHUB_INSTALLATION_ID = "48463969"
    GITHUB_APP_PRIVATE_KEY = data.onepassword_item.github_app_private_key.note_value
    WIKI_SERVER_URL        = "http://longterm-wiki-server-wiki-server.longtermwiki.svc.cluster.local"
    GITHUB_REPO            = "quantified-uncertainty/longterm-wiki"
    DAILY_RUN_CAP          = "20"
    DISCORD_WEBHOOK_URL    = data.onepassword_item.groundskeeper_discord_webhook.password
  }

  depends_on = [kubernetes_namespace.longtermwiki]
}
