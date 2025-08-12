variable "name" {
  description = "Name for the Private Endpoint"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the PE and (optionally) DNS zone will live"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to place the Private Endpoint NIC"
  type        = string
}

variable "target_resource_id" {
  description = "Resource ID of the PaaS target (e.g., SQL server ID)"
  type        = string
}

variable "subresource_names" {
  description = "Subresource names for the target (e.g., [\"sqlServer\"])"
  type        = list(string)
}

variable "manual_approval" {
  description = "Whether PE connection requires manual approval"
  type        = bool
  default     = false
}

# DNS options
variable "create_dns_zone" {
  description = "Create the private DNS zone (true) or use an existing one (false)"
  type        = bool
  default     = true
}

variable "dns_zone_name" {
  description = "Private DNS zone name (SQL: privatelink.database.windows.net)"
  type        = string
  default     = "privatelink.database.windows.net"
}

variable "dns_zone_rg_name" {
  description = "RG name for the DNS zone (defaults to module RG if null)"
  type        = string
  default     = null
}

variable "vnet_ids_for_links" {
  description = "List of VNet IDs to link to the private DNS zone"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
