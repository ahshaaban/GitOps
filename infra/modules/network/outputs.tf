# ── Network Module Outputs ────────────────────────────────────────────────────
# These outputs are consumed by downstream modules (AKS, Storage, KeyVault,
# PostgreSQL) via Terragrunt `dependency` blocks.

output "resource_group_name" {
  description = "Name of the created resource group."
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "Resource ID of the created resource group."
  value       = azurerm_resource_group.rg.id
}

output "location" {
  description = "Azure region of the resource group."
  value       = azurerm_resource_group.rg.location
}

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "Resource ID of the AKS subnet."
  value       = azurerm_subnet.aks.id
}

output "data_subnet_id" {
  description = "Resource ID of the data/private-endpoint subnet."
  value       = azurerm_subnet.data.id
}

output "postgres_subnet_id" {
  description = "Resource ID of the PostgreSQL delegated subnet."
  value       = azurerm_subnet.postgres.id
}

output "nsg_id" {
  description = "Resource ID of the network security group."
  value       = azurerm_network_security_group.nsg.id
}

output "blob_private_dns_zone_id" {
  description = "Resource ID of the blob Private DNS Zone."
  value       = azurerm_private_dns_zone.blob.id
}

output "vault_private_dns_zone_id" {
  description = "Resource ID of the Key Vault Private DNS Zone."
  value       = azurerm_private_dns_zone.vault.id
}

output "postgres_private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL Private DNS Zone."
  value       = azurerm_private_dns_zone.postgres.id
}
