# ─────────────────────────────────────────────────────────────────────────────
# Dev / Network — the foundation layer
# ─────────────────────────────────────────────────────────────────────────────
# This is ALWAYS deployed first. Every other module depends on its outputs.
#
# Interview talking point: "Network is the root of the dependency graph.
# Terragrunt's `dependency` blocks create an implicit DAG — when I run
# `terragrunt run-all apply` from the environment root, Terragrunt resolves
# the order automatically: network → keyvault → storage/postgres → aks."
# ─────────────────────────────────────────────────────────────────────────────

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../modules/network"
}

inputs = {
  resource_group_name = "${include.env.locals.prefix}-rg"
  location            = include.env.locals.location
  prefix              = include.env.locals.prefix
  address_space       = "10.0.0.0/16"
  aks_subnet_prefix   = "10.0.0.0/22"
  data_subnet_prefix  = "10.0.4.0/24"
  postgres_subnet_prefix = "10.0.5.0/24"
  tags                = include.env.locals.tags
}
