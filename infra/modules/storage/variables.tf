# ── Storage Module Variables ──────────────────────────────────────────────────

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
  description = "Random suffix for globally unique storage account name."
  type        = string
}

variable "replication_type" {
  description = "Storage replication type. LRS for dev, GRS/ZRS for prod."
  type        = string
  default     = "LRS"
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed through the storage firewall."
  type        = list(string)
  default     = []
}

variable "allowed_ip_addresses" {
  description = "List of public IPs allowed through the storage firewall (for dev/admin access)."
  type        = list(string)
  default     = []
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the Private Endpoint. Empty string disables PE creation."
  type        = string
  default     = ""
}

variable "blob_private_dns_zone_id" {
  description = "Private DNS Zone ID for blob.core.windows.net. Empty string skips DNS zone group."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings. Empty string skips."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
