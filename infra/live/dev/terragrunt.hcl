# ─────────────────────────────────────────────────────────────────────────────
# Dev Environment — Root Terragrunt Config
# ─────────────────────────────────────────────────────────────────────────────
# This file contains environment-level locals shared by all modules in dev.
#
# Interview talking point: "Each environment folder has a single terragrunt.hcl
# that defines env-specific values (location, tags, tenant). Child modules
# inherit these via `read_terragrunt_config(find_in_parent_folders())` — this
# is how Terragrunt enforces DRY across dozens of modules."
# ─────────────────────────────────────────────────────────────────────────────

locals {
  environment   = "dev"
  location      = "southafricanorth"
  prefix        = "te-${local.environment}"
  random_suffix = "d01"
  tenant_id     = "ceed7e70-3359-47e7-80d4-c30c6760c7f8"

  tags = {
    environment = local.environment
    team        = "data-platform"
    managed_by  = "terragrunt"
    project     = "azure-data-platform"
  }
}
