# Prod / Key Vault

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../modules/keyvault"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    resource_group_name       = "mock-rg"
    location                  = "southafricanorth"
    data_subnet_id            = "/subscriptions/00000000/mock-subnet"
    vault_private_dns_zone_id = "/subscriptions/00000000/mock-dns-zone"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  resource_group_name        = dependency.network.outputs.resource_group_name
  location                   = dependency.network.outputs.location
  prefix                     = include.env.locals.prefix
  random_suffix              = include.env.locals.random_suffix
  tenant_id                  = include.env.locals.tenant_id
  private_endpoint_subnet_id = dependency.network.outputs.data_subnet_id
  vault_private_dns_zone_id  = dependency.network.outputs.vault_private_dns_zone_id
  allowed_ip_addresses       = []
  tags                       = include.env.locals.tags
}
