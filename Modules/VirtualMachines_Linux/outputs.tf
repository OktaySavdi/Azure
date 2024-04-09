output "network_interface_name" {
  description = "The name of the network_interface_name"
  value       = azurerm_network_interface.vm.name
}

output "virtual_machine_name" {
  description = "The name of the virtual_machine_name"
  value       = azurerm_linux_virtual_machine.linux_vm.name
}

output "virtual_machine_location" {
  description = "The name of the virtual_machine_location"
  value       = azurerm_linux_virtual_machine.linux_vm.location
}

output "virtual_machine_vm_size" {
  description = "The name of the vm_size"
  value       = azurerm_linux_virtual_machine.linux_vm.size
}

output "extra_disks_name" {
  value = [for i in azurerm_managed_disk.extra_disks : i.name]
}

output "virtual_machine_extension_name" {
  description = "The name of the virtual_machine_extension"
  value       = [for i in azurerm_virtual_machine_extension.extension : i.name]
}
