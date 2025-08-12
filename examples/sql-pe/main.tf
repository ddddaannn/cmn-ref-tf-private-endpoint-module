terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.118"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example inputs (adjust to your environment)
variable "rg_name" {
  type    = string
  default = "rg-sql-dev-sea"
}
variable "location" {
  type    = string
  default = "southeastasia"
}
variable "subnet_id" {
  type    = string
  default = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub-sea/subnets/snet-priv-endpoints"
}
variable "sql_server_id" {
  type    = string
  default = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sql-dev-sea/providers/Microsoft.Sql/servers/sqldevsea001"
}

module "sql_pe" {
  source               = "../../modules/private_endpoint"
  name                 = "sqldevsea001-pe"
  resource_group_name  = var.rg_name
  location             = var.location

  target_resource_id   = var.sql_server_id
  subresource_names    = ["sqlServer"]

  subnet_id            = var.subnet_id

  create_dns_zone      = true
  dns_zone_name        = "privatelink.database.windows.net"
  dns_zone_rg_name     = var.rg_name

  vnet_ids_for_links   = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub-sea"
  ]

  manual_approval      = false

  tags = {
    env   = "dev"
    owner = "demo"
  }
}

output "pe_id" {
  value = module.sql_pe.private_endpoint_id
}

output "pe_ips" {
  value = module.sql_pe.private_ip_addresses
}
