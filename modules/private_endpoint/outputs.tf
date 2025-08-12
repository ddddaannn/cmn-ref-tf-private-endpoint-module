output "private_endpoint_id" {
  value       = azurerm_private_endpoint.this.id
  description = "ID of the Private Endpoint"
}

output "private_dns_zone_ids" {
  value = [
    var.create_dns_zone ? azurerm_private_dns_zone.this[0].id : data.azurerm_private_dns_zone.existing[0].id
  ]
  description = "Private DNS zone IDs associated via the zone group"
}

output "private_ip_addresses" {
  value       = local.dns_ips
  description = "Private IP addresses reported by Azure for this PE"
}
