# ─────────────────────────────────────────────────────────────────────────────
# Network Module
# ─────────────────────────────────────────────────────────────────────────────
# Creates the foundational networking layer: Resource Group, VNet, Subnets, NSG.
#
# Interview talking points:
#   - "The network module is always the FIRST to deploy because every other
#     resource depends on it for subnet placement and private connectivity."
#   - "We use separate subnets for AKS nodes, data services (PE), and
#     delegated subnets for PostgreSQL Flexible Server."
#   - "NSG rules follow a default-deny posture — only explicitly allowed
#     traffic can flow."
# ─────────────────────────────────────────────────────────────────────────────

# ── Resource Group ────────────────────────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Virtual Network ───────────────────────────────────────────────────────────
# A single VNet to contain all platform resources. The address space should be
# large enough to accommodate future growth (e.g., new subnets for Redis, etc.).
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.address_space]
  tags                = var.tags
}

# ── AKS Subnet ────────────────────────────────────────────────────────────────
# Dedicated subnet for AKS node pools. Sized /22 to allow ~1000 pod IPs
# when using Azure CNI (each pod gets a VNet IP).
resource "azurerm_subnet" "aks" {
  name                 = "${var.prefix}-aks-snet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_prefix]
  
  # Required to allow storage firewall rules for this subnet
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

# ── Data Services Subnet (Private Endpoints) ─────────────────────────────────
# Used for Private Endpoints of Storage Account, Key Vault, etc.
# Private endpoints require `private_endpoint_network_policies_enabled = false`.
resource "azurerm_subnet" "data" {
  name                                          = "${var.prefix}-data-snet"
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = [var.data_subnet_prefix]
  private_endpoint_network_policies_enabled     = false
}

# ── PostgreSQL Delegated Subnet ───────────────────────────────────────────────
# PostgreSQL Flexible Server requires a delegated subnet. This subnet cannot
# be shared with other services.
resource "azurerm_subnet" "postgres" {
  name                 = "${var.prefix}-pg-snet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.postgres_subnet_prefix]

  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ── Network Security Group ────────────────────────────────────────────────────
# Default-deny NSG attached to the AKS subnet. In production, add explicit
# allow rules for required traffic (e.g., HTTPS ingress, Azure LB health probes).
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks_nsg" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ── Private DNS Zone (for Private Endpoints) ──────────────────────────────────
# Required so that resources using Private Endpoints can resolve via DNS
# within the VNet (e.g., storageaccount.blob.core.windows.net → 10.0.x.x).
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "${var.prefix}-blob-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone" "vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vault" {
  name                  = "${var.prefix}-vault-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.prefix}-pg-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}
