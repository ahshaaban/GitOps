# ── PostgreSQL Module Variables ────────────────────────────────────────────────

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
  description = "Random suffix for globally unique server name."
  type        = string
}

variable "admin_user" {
  description = "PostgreSQL administrator login name."
  type        = string
  default     = "pgadmin"
}

variable "pg_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "15"
}

variable "sku_name" {
  description = "SKU name. Burstable for dev, GeneralPurpose for prod."
  type        = string
  default     = "B_Standard_B2ms"
}

variable "storage_mb" {
  description = "Storage size in MB."
  type        = number
  default     = 32768
}

variable "delegated_subnet_id" {
  description = "Delegated subnet ID for VNet integration."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for postgres.database.azure.com."
  type        = string
}

variable "keyvault_id" {
  description = "Key Vault ID to store the auto-generated admin password. Empty string skips."
  type        = string
  default     = ""
}

variable "backup_retention_days" {
  description = "Backup retention in days (7-35)."
  type        = number
  default     = 7
}

variable "geo_redundant_backup" {
  description = "Enable geo-redundant backups. Recommended for prod."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for the server. Set to '1', '2', or '3'."
  type        = string
  default     = "1"
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
