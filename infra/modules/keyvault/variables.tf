# ── Key Vault Module Variables ────────────────────────────────────────────────

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "prefix" {
  description = "Naming prefix (e.g., 'te-dev')."
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for globally unique vault name."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID for the Key Vault."
  type        = string
}

variable "allowed_ip_addresses" {
  description = "List of public IPs allowed through the firewall."
  type        = list(string)
  default     = []
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for Private Endpoint. Empty string disables PE."
  type        = string
  default     = ""
}

variable "vault_private_dns_zone_id" {
  description = "Private DNS Zone ID for vaultcore.azure.net. Empty string skips."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics. Empty string skips."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
