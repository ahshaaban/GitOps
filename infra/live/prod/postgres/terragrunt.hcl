# Prod / PostgreSQL — GeneralPurpose SKU, geo-backup, 35-day retention

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../modules/postgres"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    resource_group_name          = "mock-rg"
    location                     = "southafricanorth"
    postgres_subnet_id           = "/subscriptions/00000000/mock-pg-subnet"
    postgres_private_dns_zone_id = "/subscriptions/00000000/mock-dns-zone"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "keyvault" {
  config_path = "../keyvault"
  mock_outputs = {
    keyvault_id = "/subscriptions/00000000/mock-keyvault"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  resource_group_name   = dependency.network.outputs.resource_group_name
  location              = dependency.network.outputs.location
  prefix                = include.env.locals.prefix
  random_suffix         = include.env.locals.random_suffix
  admin_user            = "pgadmin"
  pg_version            = "15"
  sku_name              = "GP_Standard_D4ds_v5"   # GeneralPurpose for prod
  storage_mb            = 131072                   # 128 GB
  delegated_subnet_id   = dependency.network.outputs.postgres_subnet_id
  private_dns_zone_id   = dependency.network.outputs.postgres_private_dns_zone_id
  keyvault_id           = dependency.keyvault.outputs.keyvault_id
  backup_retention_days = 35                       # Maximum retention
  geo_redundant_backup  = true                     # DR capability
  tags                  = include.env.locals.tags
}
