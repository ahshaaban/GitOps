# ─────────────────────────────────────────────────────────────────────────────
# Prod Environment — Root Terragrunt Config
# ─────────────────────────────────────────────────────────────────────────────
# Production-specific overrides: larger subnets, GRS replication, HA postgres,
# autoscaling AKS, Azure AD integration.
#
# Interview talking point: "Spinning up prod is literally copying the dev folder
# and changing a handful of variables — the modules are identical. This is the
# power of Terragrunt's DRY architecture."
# ─────────────────────────────────────────────────────────────────────────────

locals {
  environment   = "prod"
  location      = "southafricanorth"
  prefix        = "te-${local.environment}"
  random_suffix = "p01"
  tenant_id     = "ceed7e70-3359-47e7-80d4-c30c6760c7f8"

  tags = {
    environment = local.environment
    team        = "data-platform"
    managed_by  = "terragrunt"
    project     = "azure-data-platform"
    criticality = "high"
  }
}
