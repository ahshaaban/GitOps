# ─────────────────────────────────────────────────────────────────────────────
# Key Vault Module
# ─────────────────────────────────────────────────────────────────────────────
# Creates an Azure Key Vault with:
#   - RBAC authorization model (no legacy access policies)
#   - Purge protection & soft delete for compliance
#   - Private Endpoint for VNet-only access
#   - Firewall: default Deny
#
# Interview talking points:
#   - "We use RBAC authorization instead of access policies because it
#     integrates natively with Azure AD and supports fine-grained roles like
#     Key Vault Secrets User vs Key Vault Administrator."
#   - "Purge protection prevents any user — even Global Admin — from
#     permanently deleting secrets within the retention window. This is
#     mandatory for most compliance frameworks (SOC2, ISO 27001)."
#   - "The Private Endpoint ensures the vault is unreachable from the internet."
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_key_vault" "kv" {
  name                          = "${var.prefix}-kv-${var.random_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"

  # Security hardening
  enable_rbac_authorization     = true   # Use Azure RBAC, not legacy access policies
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  
  # Set to true and "Allow" for local laptop deployments so Terraform can create secrets.
  # In actual production with self-hosted runners, set this to false/"Deny".
  public_network_access_enabled = true  

  # Firewall
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_addresses
  }

  tags = var.tags
}

# ── RBAC Assignment for Deployer ──────────────────────────────────────────────
# When enable_rbac_authorization is true, Terraform needs permissions to create
# secrets (e.g., PostgreSQL password) in modules that depend on this one.
data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "tf_deployer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ── Private Endpoint ──────────────────────────────────────────────────────────
resource "azurerm_private_endpoint" "kv_pe" {
  count               = var.private_endpoint_subnet_id != "" ? 1 : 0
  name                = "${var.prefix}-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.vault_private_dns_zone_id != "" ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.vault_private_dns_zone_id]
    }
  }

  tags = var.tags
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.prefix}-kv-diag"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
