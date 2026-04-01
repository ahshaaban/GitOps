# ── Network Module Variables ──────────────────────────────────────────────────

variable "resource_group_name" {
  description = "Name of the resource group to create."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "prefix" {
  description = "Naming prefix applied to all resources (e.g., 'te-dev')."
  type        = string
}

variable "address_space" {
  description = "VNet address space in CIDR notation. Use /16 for growth."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_prefix" {
  description = "Subnet CIDR for AKS node pools. /22 supports ~1000 pods with Azure CNI."
  type        = string
  default     = "10.0.0.0/22"
}

variable "data_subnet_prefix" {
  description = "Subnet CIDR for Private Endpoints (Storage, Key Vault)."
  type        = string
  default     = "10.0.4.0/24"
}

variable "postgres_subnet_prefix" {
  description = "Delegated subnet CIDR for PostgreSQL Flexible Server."
  type        = string
  default     = "10.0.5.0/24"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
