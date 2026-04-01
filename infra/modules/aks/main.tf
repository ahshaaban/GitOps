# ─────────────────────────────────────────────────────────────────────────────
# AKS Module
# ─────────────────────────────────────────────────────────────────────────────
# Creates an Azure Kubernetes Service cluster with:
#   - SystemAssigned Managed Identity (no service principal secrets)
#   - OIDC Issuer for Workload Identity (pod-level Azure AD auth)
#   - Azure CNI networking (pods get VNet IPs)
#   - Azure Network Policy for pod-to-pod traffic control
#   - Optional Azure AD integration for Kubernetes RBAC
#   - Workload Identity enabled for secretless pod auth
#
# Interview talking points:
#   - "SystemAssigned identity means Azure manages the lifecycle — no secret
#     rotation burden. The identity is destroyed when the cluster is destroyed."
#   - "OIDC Issuer + Workload Identity eliminates ALL secrets inside pods.
#     A pod's ServiceAccount gets a federated token that Azure AD trusts."
#   - "Azure CNI gives each pod a real VNet IP, enabling direct communication
#     with Private Endpoints (ADLS, KeyVault, PostgreSQL) without NAT."
#   - "Network Policy 'azure' allows us to define Kubernetes NetworkPolicy
#     resources to control east-west pod traffic (micro-segmentation)."
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # ── System Node Pool ──────────────────────────────────────────────────────
  # Dedicated to system workloads (CoreDNS, kube-proxy, metrics-server).
  # For prod, use a separate user node pool for application workloads.
  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.system_node_min : null
    max_count           = var.enable_auto_scaling ? var.system_node_max : null

    # Best practice: taint system nodes so user workloads don't schedule here
    only_critical_addons_enabled = true

    tags = var.tags
  }

  # ── Identity ──────────────────────────────────────────────────────────────
  identity {
    type = "SystemAssigned"
  }

  # ── Workload Identity (OIDC) ──────────────────────────────────────────────
  # Enables pods to authenticate to Azure AD without any secrets.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # ── Azure AD Integration ──────────────────────────────────────────────────
  # When enabled, Kubernetes RBAC is backed by Azure AD groups.
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_azure_ad ? [1] : []
    content {
      managed                = true
      azure_rbac_enabled     = true
      admin_group_object_ids = var.azure_ad_admin_group_object_ids
    }
  }

  # ── Networking ────────────────────────────────────────────────────────────
  network_profile {
    network_plugin    = "azure"        # Azure CNI — pods get VNet IPs
    network_policy    = "azure"        # Azure Network Policy for micro-segmentation
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  # ── Monitoring ────────────────────────────────────────────────────────────
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != "" ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # ── Key Vault Secrets Provider (CSI) ──────────────────────────────────────
  # Mounts Key Vault secrets directly into pods as volumes.
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}

# ── User Node Pool (for application workloads) ─────────────────────────────
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  count                 = var.create_user_node_pool ? 1 : 0
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_vm_size
  node_count            = var.user_node_count
  vnet_subnet_id        = var.vnet_subnet_id
  os_disk_size_gb       = 128
  os_disk_type          = "Managed"
  enable_auto_scaling   = var.enable_auto_scaling
  min_count             = var.enable_auto_scaling ? var.user_node_min : null
  max_count             = var.enable_auto_scaling ? var.user_node_max : null
  mode                  = "User"

  tags = var.tags
}
