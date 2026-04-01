# ─────────────────────────────────────────────────────────────────────────────
# Root Terragrunt Configuration
# ─────────────────────────────────────────────────────────────────────────────
# We specify 'tofu' as our default binary to embrace 100% open-source IaC.
terraform_binary = "tofu"

# This file is the single source of truth for:
#   1. Remote state backend configuration (Azure Storage)
#   2. Global provider settings
#   3. Shared locals (naming prefix)
#
# Interview talking point: "We use a root HCL to enforce a consistent backend
# across ALL environments and modules, preventing state-file sprawl."
# ─────────────────────────────────────────────────────────────────────────────

# ── Remote State ──────────────────────────────────────────────────────────────
# Terragrunt will auto-create the storage container if it doesn't exist.
# The `key` uses `path_relative_to_include()` so each module in each
# environment gets its own isolated state file, e.g.:
#   dev/network.tfstate, dev/aks.tfstate, prod/network.tfstate, etc.
# ─────────────────────────────────────────────────────────────────────────────
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = "te-terraform-state"
    storage_account_name = "tfterraformstate001"
    container_name       = "terraform-state"
    key                  = "${path_relative_to_include()}.tfstate"
  }
}

# ── Provider Generation ───────────────────────────────────────────────────────
# Generate a consistent azurerm provider block for every module so we don't
# repeat it inside each module's main.tf.
#
# Interview talking point: "Generating the provider from the root config
# ensures every module uses the same provider version and features block,
# preventing version drift across environments."
# ─────────────────────────────────────────────────────────────────────────────
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.5.0"
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 3.100"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.6"
        }
      }
    }

    provider "azurerm" {
      storage_use_azuread = true  # Prevents TF from fetching storage keys, relying on Entra ID
      features {
        key_vault {
          purge_soft_delete_on_destroy    = false
          recover_soft_deleted_key_vaults = true
        }
      }
    }
  EOF
}

# ── Shared Locals ─────────────────────────────────────────────────────────────
locals {
  prefix = "te"
}
