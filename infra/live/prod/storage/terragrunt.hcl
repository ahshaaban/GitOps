# Prod / Storage — GRS replication for disaster recovery

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
  replication_type           = "GRS"    # Geo-redundant for production
  allowed_subnet_ids         = [dependency.network.outputs.aks_subnet_id]
  private_endpoint_subnet_id = dependency.network.outputs.data_subnet_id
  blob_private_dns_zone_id   = dependency.network.outputs.blob_private_dns_zone_id
  tags                       = include.env.locals.tags
}
