output "resource_group_ids" {
  description = "IDs of the created Azure Resource Groups"
  value       = azurerm_resource_group.rg[*].id
}

output "resource_group_names" {
  description = "Names of the created Azure Resource Groups"
  value       = azurerm_resource_group.rg[*].name
}

output "resource_group_locations" {
  description = "Locations of the created Azure Resource Groups"
  value       = azurerm_resource_group.rg[*].location
}
