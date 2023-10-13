output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.name, [""]), 0)
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.id, [""]), 0)
}


output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = [for n in azurerm_network_security_group.nsg : n.id]
}
