terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
  }
}

# Optional: if you want to look up RG or VNet elsewhere, take them as vars.
# This module expects: subnet_id, target_resource_id, etc.

locals {
  # DNS zone(s) you want to associate to the PE
  zone_rg_name = coalesce(var.dns_zone_rg_name, var.resource_group_name)
}

# Create or reference the private DNS zone (SQL default shown)
resource "azurerm_private_dns_zone" "this" {
  count               = var.create_dns_zone ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = local.zone_rg_name
  tags                = var.tags
}

data "azurerm_private_dns_zone" "existing" {
  count               = var.create_dns_zone ? 0 : 1
  name                = var.dns_zone_name
  resource_group_name = local.zone_rg_name
}

# VNet links (one per VNet provided)
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each              = toset(var.vnet_ids_for_links)
  name                  = replace(each.value, "/","-")
  resource_group_name   = local.zone_rg_name
  private_dns_zone_name = var.create_dns_zone ? azurerm_private_dns_zone.this[0].name : data.azurerm_private_dns_zone.existing[0].name
  virtual_network_id    = each.value
  registration_enabled  = false
  tags                  = var.tags
}

# Private Endpoint
resource "azurerm_private_endpoint" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = var.target_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = var.manual_approval
  }

  # Associate the DNS zone(s) using a zone group
  private_dns_zone_group {
    name = "${var.name}-zonegrp"
    private_dns_zone_ids = [
      var.create_dns_zone ? azurerm_private_dns_zone.this[0].id : data.azurerm_private_dns_zone.existing[0].id
    ]
  }
}

# Optional: output-friendly list of IPs based on DNS configs Azure returns
locals {
  dns_ips = flatten([
    for cfg in azurerm_private_endpoint.this.custom_dns_configs : cfg.ip_addresses
  ])
}
