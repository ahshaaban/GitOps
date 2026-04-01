# ─────────────────────────────────────────────────────────────────────────────
# Dev / PostgreSQL — database layer
# ─────────────────────────────────────────────────────────────────────────────
# Depends on: network (delegated subnet, DNS zone), keyvault (password storage)
#
# Interview talking point: "PostgreSQL depends on BOTH network and keyvault.
# Terragrunt resolves this multi-parent dependency automatically. The admin
# password is generated at apply-time by the `random_password` resource and
# stored directly in Key Vault — it never exists in plain text in our config."
# ─────────────────────────────────────────────────────────────────────────────

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
  resource_group_name = dependency.network.outputs.resource_group_name
  location            = dependency.network.outputs.location
  prefix              = include.env.locals.prefix
  random_suffix       = include.env.locals.random_suffix
  admin_user          = "pgadmin"
  pg_version          = "15"
  sku_name            = "B_Standard_B2ms"      # Burstable for dev
  storage_mb          = 32768                   # 32 GB
  delegated_subnet_id = dependency.network.outputs.postgres_subnet_id
  private_dns_zone_id = dependency.network.outputs.postgres_private_dns_zone_id
  keyvault_id         = dependency.keyvault.outputs.keyvault_id
  backup_retention_days = 7
  geo_redundant_backup  = false                 # No geo-backup for dev
  tags                  = include.env.locals.tags
}
