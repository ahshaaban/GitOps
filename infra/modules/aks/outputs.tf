# ── AKS Module Outputs ────────────────────────────────────────────────────────

output "cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity (for RBAC assignments)."
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity federation."
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "node_resource_group" {
  description = "Auto-generated resource group containing AKS infrastructure."
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}
