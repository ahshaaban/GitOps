# ─────────────────────────────────────────────────────────────────────────────
# Storage Module — ADLS Gen2
# ─────────────────────────────────────────────────────────────────────────────
# Creates an Azure Data Lake Storage Gen2 account with:
#   - Hierarchical Namespace (HNS) for directory-level ACLs
#   - Firewall: default Deny + bypass for Azure services
#   - Private Endpoint for VNet-only access
#   - Data Lake filesystem containers (bronze/silver/gold medallion)
#
# Interview talking points:
#   - "HNS enables POSIX-like ACLs and atomic directory operations which are
#     critical for data lake workloads (Spark, Synapse, Databricks)."
#   - "The firewall + Private Endpoint pattern ensures data never traverses
#     the public internet — a key compliance requirement."
#   - "We use the medallion architecture (bronze/silver/gold) to separate
#     raw ingestion, cleansed, and curated layers."
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_storage_account" "adls" {
  name                     = lower(replace("${var.prefix}adls${var.random_suffix}", "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"
  is_hns_enabled           = true                # Enables ADLS Gen2

  # Security hardening
  allow_nested_items_to_be_public = false         # Block anonymous blob access
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = true          # Enabled for local Terraform Data Plane operations
  infrastructure_encryption_enabled = true        # Double encryption at rest

  # Firewall 
  # Set to "Allow" for local laptop deployments. In production CI/CD (using a self-hosted
  # runner inside a VNet), this MUST be set to "Deny".
  network_rules {
    default_action             = "Allow"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = var.allowed_subnet_ids
    ip_rules                   = var.allowed_ip_addresses
  }

  tags = var.tags
}

# ── Data Lake Filesystem Containers (Medallion Architecture) ──────────────────
resource "azurerm_storage_data_lake_gen2_filesystem" "bronze" {
  name               = "bronze"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "silver" {
  name               = "silver"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gold" {
  name               = "gold"
  storage_account_id = azurerm_storage_account.adls.id
}

# ── Private Endpoint ──────────────────────────────────────────────────────────
# Connects the storage account to the VNet so traffic stays on Microsoft backbone.
resource "azurerm_private_endpoint" "adls_pe" {
  count               = var.private_endpoint_subnet_id != "" ? 1 : 0
  name                = "${var.prefix}-adls-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.prefix}-adls-psc"
    private_connection_resource_id = azurerm_storage_account.adls.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.blob_private_dns_zone_id != "" ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.blob_private_dns_zone_id]
    }
  }

  tags = var.tags
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────
# Send storage metrics and logs to a Log Analytics workspace for monitoring.
resource "azurerm_monitor_diagnostic_setting" "adls_diag" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.prefix}-adls-diag"
  target_resource_id         = azurerm_storage_account.adls.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "Transaction"
    enabled  = true
  }
}
