data "azurerm_disk_access" "disk_access" {
  name                = var.disk_access_name
  resource_group_name = var.disk_access_resource_group_name
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

#---------------------------------------
# Linux Virutal machine
#---------------------------------------
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                         = "az-vm-${var.vm_hostname}-${var.team_name}-${var.environment}"
  computer_name                = var.vm_hostname
  resource_group_name          = var.resource_group_name
  location                     = var.location
  size                         = var.size
  disable_password_authentication = var.disable_password_authentication
  admin_username               = var.admin_username
  admin_password               = var.admin_password
  network_interface_ids        = ["${azurerm_network_interface.vm.id}"]
  source_image_id              = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent           = true
  allow_extension_operations   = true
  #secure_boot_enabled          = true
  availability_set_id          = var.availability_set_enabled ? azurerm_availability_set.vm[0].id : null
  zone                         = var.zone
  tags                         = var.tags

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.admin_ssh_key_data == null ? tls_private_key.rsa[0].public_key_openssh : file("/home/${var.admin_username}/.ssh/authorized_keys")
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.os_image_referance != null ? var.vm_os_publisher : null
      offer     = var.os_image_referance != null ? var.vm_os_offer : null
      sku       = var.os_image_referance != null ? var.vm_os_sku : null
      version   = var.os_image_referance != null ? var.vm_os_version : null
    }
  }

  os_disk {
    storage_account_type      = var.data_sa_type
    caching                   = "ReadWrite"
    disk_size_gb              = var.data_disk_size_gb
    name                      = "az-disk-${var.vm_hostname}-${var.team_name}-${var.environment}"
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_managed_disk" "extra_disks" {
  count                         = length(var.extra_disks)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_access_policy         = var.network_access_policy
  disk_access_id                = data.azurerm_disk_access.disk_access.id
  public_network_access_enabled = var.public_network_access_enabled
  #os_type                       = var.os_type

  name                 = var.extra_disks[count.index].name
  create_option        = var.extra_disks[count.index].create_option
  storage_account_type = var.extra_disks[count.index].storage_account_type
  disk_size_gb         = var.extra_disks[count.index].disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_extra_disk_attachments" {
  count              = length(azurerm_managed_disk.extra_disks)
  virtual_machine_id = azurerm_linux_virtual_machine.linux_vm.id
  managed_disk_id    = azurerm_managed_disk.extra_disks[count.index].id
  lun                = count.index
  caching            = "ReadWrite"

  depends_on = [azurerm_managed_disk.extra_disks, azurerm_linux_virtual_machine.linux_vm]
}

resource "azurerm_virtual_machine_extension" "extension" {
  count                       = length(var.vm_extensions)
  name                        = var.vm_extensions[count.index].name
  publisher                   = var.vm_extensions[count.index].publisher
  type                        = var.vm_extensions[count.index].type
  type_handler_version        = var.vm_extensions[count.index].type_handler_version
  virtual_machine_id          = azurerm_linux_virtual_machine.linux_vm.id
  auto_upgrade_minor_version  = var.vm_extensions[count.index].auto_upgrade_minor_version
  automatic_upgrade_enabled   = var.vm_extensions[count.index].automatic_upgrade_enabled
  failure_suppression_enabled = var.vm_extensions[count.index].failure_suppression_enabled
  settings                    = var.vm_extensions[count.index].settings

  depends_on = [azurerm_linux_virtual_machine.linux_vm, azurerm_managed_disk.extra_disks]
}
