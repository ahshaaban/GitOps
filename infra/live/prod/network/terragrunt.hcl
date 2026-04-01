# Prod / Network — uses a larger address space for growth headroom

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
  resource_group_name    = "${include.env.locals.prefix}-rg"
  location               = include.env.locals.location
  prefix                 = include.env.locals.prefix
  address_space          = "10.1.0.0/16"        # Separate from dev (10.0.x)
  aks_subnet_prefix      = "10.1.0.0/22"
  data_subnet_prefix     = "10.1.4.0/24"
  postgres_subnet_prefix = "10.1.5.0/24"
  tags                   = include.env.locals.tags
}
