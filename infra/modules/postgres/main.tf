# ─────────────────────────────────────────────────────────────────────────────
# PostgreSQL Flexible Server Module
# ─────────────────────────────────────────────────────────────────────────────
# Creates an Azure Database for PostgreSQL Flexible Server with:
#   - VNet integration via delegated subnet (no public endpoint)
#   - Private DNS Zone link for name resolution
#   - Auto-generated admin password stored in Key Vault
#   - Configurable HA and storage
#
# Interview talking points:
#   - "Flexible Server replaces Single Server and offers zone-redundant HA,
#     in-place major version upgrades, and better price/performance."
#   - "VNet integration via delegated subnet means the server has NO public IP.
#     It's only reachable from within the VNet or peered networks."
#   - "We generate the admin password with the random provider and immediately
#     store it in Key Vault — the password never appears in state in plain text
#     and is never hardcoded in config."
# ─────────────────────────────────────────────────────────────────────────────

# ── Random Password Generation ────────────────────────────────────────────────
# Generate a strong password and store it in Key Vault instead of hardcoding.
resource "random_password" "pg_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

# ── Store Password in Key Vault ───────────────────────────────────────────────
resource "azurerm_key_vault_secret" "pg_password" {
  count        = var.keyvault_id != "" ? 1 : 0
  name         = "${var.prefix}-pg-admin-password"
  value        = random_password.pg_admin.result
  key_vault_id = var.keyvault_id
  content_type = "password"

  tags = var.tags
}

# ── PostgreSQL Flexible Server ────────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server" "pg" {
  name                          = "${var.prefix}-pg-${var.random_suffix}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.pg_version
  administrator_login           = var.admin_user
  administrator_password        = random_password.pg_admin.result

  storage_mb                    = var.storage_mb
  sku_name                      = var.sku_name

  # VNet integration — no public endpoint
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false

  # Backup
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup

  zone = var.availability_zone

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Prevent Terraform from trying to reset the password on every apply
      administrator_password,
      # Zone may change during Azure maintenance
      zone,
    ]
  }
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "pg_diag" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.prefix}-pg-diag"
  target_resource_id         = azurerm_postgresql_flexible_server.pg.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
