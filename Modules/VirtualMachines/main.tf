data "azurerm_disk_access" "disk_access" {
  name                = var.disk_access_name
  resource_group_name = var.disk_access_resource_group_name
}

resource "azurerm_managed_disk" "os_disk" {
  name                 = "az-disk-${var.vm_hostname}-${var.team_name}-${var.environment}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_sa_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags

  network_access_policy = var.network_access_policy
  disk_access_id        = data.azurerm_disk_access.disk_access.id
}

resource "azurerm_network_interface" "vm" {
  location                      = var.location
  name                          = "az-nic-${var.vm_hostname}-${var.team_name}-${var.environment}"
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking
  enable_ip_forwarding          = var.enable_ip_forwarding
  tags                          = var.tags

  ip_configuration {
    name                          = "${var.vm_hostname}-ip-${var.environment}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.vnet_subnet_id
  }
}

resource "azurerm_availability_set" "vm" {
  count                        = var.availability_set_enabled == true ? 1 : 0
  location                     = var.location
  name                         = "az-as-${var.vm_hostname}-${var.team_name}-${var.environment}"
  resource_group_name          = var.resource_group_name
  managed                      = true
  platform_fault_domain_count  = var.as_platform_fault_domain_count
  platform_update_domain_count = var.as_platform_update_domain_count
  tags                         = var.tags
}

resource "azurerm_virtual_machine" "vm_linux_windows" {
  location                         = var.location
  name                             = "az-vm-${var.vm_hostname}-${var.team_name}-${var.environment}"
  network_interface_ids            = ["${azurerm_network_interface.vm.id}"]
  resource_group_name              = var.resource_group_name
  vm_size                          = var.vm_size
  availability_set_id              = var.availability_set_enabled ? azurerm_availability_set.vm[0].id : null
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  zones                            = var.availability_set_enabled ? null : var.zones
  tags                             = var.tags

  storage_os_disk {
    create_option   = "Attach"
    name            = "az-disk-${var.vm_hostname}-${var.team_name}-${var.environment}"
    caching         = "ReadWrite"
    managed_disk_id = azurerm_managed_disk.os_disk.id
    os_type         = var.os_type
  }
  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []

    content {
      type = var.identity_type
    }
  }
  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []

    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }
  #os_profile { # https://learn.microsoft.com/en-us/azure/virtual-machines/troubleshooting-shared-images#creating-or-updating-a-vm-or-scale-sets-from-an-image-version
  #  admin_username = var.admin_username
  #  computer_name  = "az-vm-${var.vm_hostname}-${var.team_name}-${var.environment}"
  #  admin_password = var.admin_password
  #  #custom_data   = var.custom_data
  #}
  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key

    dynamic "ssh_keys" {
      for_each = var.enable_ssh_key ? var.ssh_key_values : []

      content {
        key_data = ssh_keys.value
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.nested_data_disks || var.delete_data_disks_on_termination != true
      error_message = "`var.nested_data_disks` must be `true` when `var.delete_data_disks_on_termination` is `true`, because when you declare data disks via separate managed disk resource, you might want to preserve the data while recreating the vm instance."
    }
  }
}

resource "azurerm_managed_disk" "extra_disks" {
  count                 = length(var.extra_disks)
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_access_policy = var.network_access_policy
  disk_access_id        = data.azurerm_disk_access.disk_access.id
  os_type               = var.os_type

  name                 = var.extra_disks[count.index].name
  create_option        = var.extra_disks[count.index].create_option
  storage_account_type = var.extra_disks[count.index].storage_account_type
  disk_size_gb         = var.extra_disks[count.index].disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_extra_disk_attachments" {
  count              = length(azurerm_managed_disk.extra_disks)
  virtual_machine_id = azurerm_virtual_machine.vm_linux_windows.id
  managed_disk_id    = azurerm_managed_disk.extra_disks[count.index].id
  lun                = count.index
  caching            = "ReadWrite"

  depends_on = [azurerm_managed_disk.extra_disks, azurerm_virtual_machine.vm_linux_windows]
}

resource "azurerm_virtual_machine_extension" "extension" {
  count                       = length(var.vm_extensions)
  name                        = var.vm_extensions[count.index].name
  publisher                   = var.vm_extensions[count.index].publisher
  type                        = var.vm_extensions[count.index].type
  type_handler_version        = var.vm_extensions[count.index].type_handler_version
  virtual_machine_id          = azurerm_virtual_machine.vm_linux_windows.id
  auto_upgrade_minor_version  = var.vm_extensions[count.index].auto_upgrade_minor_version
  automatic_upgrade_enabled   = var.vm_extensions[count.index].automatic_upgrade_enabled
  failure_suppression_enabled = var.vm_extensions[count.index].failure_suppression_enabled
  settings                    = var.vm_extensions[count.index].settings

  depends_on = [azurerm_virtual_machine.vm_linux_windows, azurerm_managed_disk.extra_disks]
}
