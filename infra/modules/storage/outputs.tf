# ── Storage Module Outputs ────────────────────────────────────────────────────

output "storage_account_id" {
  description = "Resource ID of the ADLS Gen2 storage account."
  value       = azurerm_storage_account.adls.id
}

output "storage_account_name" {
  description = "Name of the ADLS Gen2 storage account."
  value       = azurerm_storage_account.adls.name
}

output "primary_dfs_endpoint" {
  description = "Primary DFS endpoint for Data Lake operations."
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "primary_blob_endpoint" {
  description = "Primary Blob endpoint."
  value       = azurerm_storage_account.adls.primary_blob_endpoint
}
