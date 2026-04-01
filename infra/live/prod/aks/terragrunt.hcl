# ─────────────────────────────────────────────────────────────────────────────
# Prod / AKS — autoscaling, Azure AD RBAC, user node pool
# ─────────────────────────────────────────────────────────────────────────────
# Interview talking point: "Compare this with the dev config. Same module,
# but prod enables autoscaling (2-5 system, 2-10 user), a dedicated user node
# pool, and Azure AD integration. This is why modular IaC matters — one module
# serves both environments with different inputs."
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

  # Prod sizing — autoscaling with dedicated user pool
  system_node_count     = 3
  system_node_vm_size   = "Standard_DS3_v2"
  enable_auto_scaling   = true
  system_node_min       = 3
  system_node_max       = 5

  create_user_node_pool = true
  user_node_count       = 2
  user_node_vm_size     = "Standard_DS3_v2"
  user_node_min         = 2
  user_node_max         = 10

  # Azure AD RBAC
  enable_azure_ad       = true
  azure_ad_admin_group_object_ids = []   # Add your AD group object IDs

  tags = include.env.locals.tags
}
