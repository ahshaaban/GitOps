# ─────────────────────────────────────────────────────────────────────────────
# Dev / AKS — compute layer
# ─────────────────────────────────────────────────────────────────────────────
# Depends on: network (AKS subnet)
#
# Interview talking point: "AKS is the last infrastructure component. Once it's
# up, we switch from 'provisioning' to 'configuration' — GitHub Actions (Push-Based GitOps)
# takes over and continuously applies the k8s/ manifests to the cluster.
# This separation of concerns means infra engineers own Terraform/Terragrunt
# and platform engineers own the k8s manifests."
# ─────────────────────────────────────────────────────────────────────────────

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../modules/aks"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    resource_group_name = "mock-rg"
    location            = "southafricanorth"
    aks_subnet_id       = "/subscriptions/00000000/mock-aks-subnet"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  resource_group_name   = dependency.network.outputs.resource_group_name
  location              = dependency.network.outputs.location
  prefix                = include.env.locals.prefix
  cluster_name          = "aks"
  dns_prefix            = "${include.env.locals.prefix}-aks"
  kubernetes_version    = "1.32"
  vnet_subnet_id        = dependency.network.outputs.aks_subnet_id

  # Dev sizing — small, no autoscaling, no user pool
  system_node_count     = 2
  system_node_vm_size   = "Standard_DS2_v2"
  enable_auto_scaling   = false
  create_user_node_pool = false

  # Disable Azure AD for dev (enable in prod)
  enable_azure_ad       = false

  tags = include.env.locals.tags
}
