# ── AKS Module Variables ──────────────────────────────────────────────────────

variable "prefix" {
  description = "Naming prefix (e.g., 'te-dev')."
  type        = string
}

variable "cluster_name" {
  description = "Cluster name suffix (combined with prefix)."
  type        = string
  default     = "aks"
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version. Pin in prod to avoid surprise upgrades."
  type        = string
  default     = "1.32"
}

# ── System Node Pool ─────────────────────────────────────────────────────────

variable "system_node_count" {
  description = "Number of system nodes (if autoscaling disabled)."
  type        = number
  default     = 2
}

variable "system_node_vm_size" {
  description = "VM size for system node pool."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "system_node_min" {
  description = "Min nodes for system pool autoscaler."
  type        = number
  default     = 2
}

variable "system_node_max" {
  description = "Max nodes for system pool autoscaler."
  type        = number
  default     = 5
}

# ── User Node Pool ───────────────────────────────────────────────────────────

variable "create_user_node_pool" {
  description = "Whether to create a separate user node pool for app workloads."
  type        = bool
  default     = false
}

variable "user_node_count" {
  description = "Number of user nodes (if autoscaling disabled)."
  type        = number
  default     = 2
}

variable "user_node_vm_size" {
  description = "VM size for user node pool."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "user_node_min" {
  description = "Min nodes for user pool autoscaler."
  type        = number
  default     = 1
}

variable "user_node_max" {
  description = "Max nodes for user pool autoscaler."
  type        = number
  default     = 10
}

# ── Networking ───────────────────────────────────────────────────────────────

variable "vnet_subnet_id" {
  description = "Subnet ID for AKS nodes. Required for Azure CNI."
  type        = string
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services. Must not overlap with VNet."
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP. Must be within service_cidr."
  type        = string
  default     = "172.16.0.10"
}

# ── Features ─────────────────────────────────────────────────────────────────

variable "enable_auto_scaling" {
  description = "Enable cluster autoscaler on node pools."
  type        = bool
  default     = false
}

variable "enable_azure_ad" {
  description = "Enable Azure AD integration for Kubernetes RBAC."
  type        = bool
  default     = false
}

variable "azure_ad_admin_group_object_ids" {
  description = "Azure AD group object IDs for cluster-admin role."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for Container Insights. Empty string skips."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
