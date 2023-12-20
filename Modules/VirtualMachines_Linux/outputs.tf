output "os_disk_name" {
  description = "The name of the disk name."
  value       = azurerm_managed_disk.os_disk.name
}

output "os_disk_gallery_image_reference_id" {
  description = "The name of the os_disk_gallery_image_reference_id"
  value       = azurerm_managed_disk.os_disk.gallery_image_reference_id
}

output "os_disk_size_gb" {
  description = "The name of the os_disk_size_gb"
  value       = azurerm_managed_disk.os_disk.disk_size_gb
}

output "os_disk_network_access_policy" {
  description = "The name of the os_disk_network_access_policy"
  value       = azurerm_managed_disk.os_disk.network_access_policy
}

output "os_disk_access_id" {
  description = "The name of the os_disk_access_id"
  value       = azurerm_managed_disk.os_disk.disk_access_id
}

output "os_disk_public_network_access_enabled" {
  description = "The name of the os_disk_public_network_access_enabled"
  value       = azurerm_managed_disk.os_disk.public_network_access_enabled
}

output "network_interface_name" {
  description = "The name of the network_interface_name"
  value       = azurerm_network_interface.vm.name
}

output "virtual_machine_name" {
  description = "The name of the virtual_machine_name"
  value       = azurerm_virtual_machine.vm_linux.name
}

output "virtual_machine_location" {
  description = "The name of the virtual_machine_location"
  value       = azurerm_virtual_machine.vm_linux.location
}

output "virtual_machine_vm_size" {
  description = "The name of the vm_size"
  value       = azurerm_virtual_machine.vm_linux.vm_size
}

output "extra_disks_name" {
  value = [for i in azurerm_managed_disk.extra_disks : i.name]
}

output "virtual_machine_extension_name" {
  description = "The name of the virtual_machine_extension"
  value      = [for i in azurerm_virtual_machine_extension.extension : i.name]
}
