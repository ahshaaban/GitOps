# ── Key Vault Module Outputs ──────────────────────────────────────────────────

output "keyvault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "keyvault_uri" {
  description = "Vault URI for SDK/CLI access."
  value       = azurerm_key_vault.kv.vault_uri
}

output "keyvault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.kv.name
}
