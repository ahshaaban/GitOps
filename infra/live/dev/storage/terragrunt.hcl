# ─────────────────────────────────────────────────────────────────────────────
# Dev / Storage (ADLS Gen2) — data lake layer
# ─────────────────────────────────────────────────────────────────────────────
# Depends on: network (for RG, AKS subnet allowlist, PE subnet, DNS zone)
#
# Interview talking point: "The storage firewall allows traffic from the AKS
# subnet so pods can access the data lake, but blocks all public access.
# Combined with the Private Endpoint, data never leaves the Microsoft backbone."
# ─────────────────────────────────────────────────────────────────────────────

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../modules/storage"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    resource_group_name      = "mock-rg"
    location                 = "southafricanorth"
    aks_subnet_id            = "/subscriptions/00000000/mock-aks-subnet"
    data_subnet_id           = "/subscriptions/00000000/mock-data-subnet"
    blob_private_dns_zone_id = "/subscriptions/00000000/mock-dns-zone"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  resource_group_name        = dependency.network.outputs.resource_group_name
  location                   = dependency.network.outputs.location
  prefix                     = include.env.locals.prefix
  random_suffix              = include.env.locals.random_suffix
  replication_type           = "LRS"   # LRS for dev, GRS for prod
  allowed_subnet_ids         = [dependency.network.outputs.aks_subnet_id]
  private_endpoint_subnet_id = dependency.network.outputs.data_subnet_id
  blob_private_dns_zone_id   = dependency.network.outputs.blob_private_dns_zone_id
  tags                       = include.env.locals.tags
}
