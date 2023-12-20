data "azurerm_disk_access" "disk_access" {
  name                = var.disk_access_name
  resource_group_name = var.disk_access_resource_group_name
}

# enable if you want to use disk snapshot instead of image referance
#resource "azurerm_snapshot" "example" {
#  name                = "<snapshot-name>"
#  location            = "germanywestcentral"
#  resource_group_name = "<rg>"
#  create_option       = "Copy"
#  source_uri          = "/subscriptions/<subscription_id>/resourceGroups/<rg>/providers/Microsoft.Compute/disks/<disk_name>"
#}

resource "azurerm_managed_disk" "os_disk" {
  name                 = "az-disk-${var.vm_hostname}-${var.team_name}-${var.environment}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_sa_type
  create_option        = "FromImage"
  gallery_image_reference_id  = var.gallery_image_reference_id
  #source_resource_id   = azurerm_snapshot.example.id # enable if you want to use disk snapshot instead of image referance
  os_type              = var.os_type

  disk_size_gb = var.data_disk_size_gb
  tags         = var.tags

  network_access_policy         = var.network_access_policy
  disk_access_id                = data.azurerm_disk_access.disk_access.id
  public_network_access_enabled = var.public_network_access_enabled
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

resource "azurerm_virtual_machine" "vm_windows" {
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

  ## we used disk attach thay's why it mush be disable
  #storage_image_reference {
  #  publisher = var.vm_os_publisher
  #  offer     = var.vm_os_offer
  #  sku       = var.vm_os_sku
  #  version   = "latest"
  #}

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
 
  ## we used disk attach thay's why it mush be disable
  #os_profile { # https://learn.microsoft.com/en-us/azure/virtual-machines/troubleshooting-shared-images#creating-or-updating-a-vm-or-scale-sets-from-an-image-version
  #  admin_username = var.admin_username
  #  computer_name  = "az-vm-${var.vm_hostname}-${var.team_name}-${var.environment}"
  #  admin_password = var.admin_password
  #  #custom_data   = var.custom_data
  #}

  os_profile_windows_config {
    provision_vm_agent = var.provision_vm_agent
    enable_automatic_upgrades = var.enable_automatic_upgrades
    timezone = var.timezone
  }

  lifecycle {
    precondition {
      condition     = var.nested_data_disks || var.delete_data_disks_on_termination != true
      error_message = "`var.nested_data_disks` must be `true` when `var.delete_data_disks_on_termination` is `true`, because when you declare data disks via separate managed disk resource, you might want to preserve the data while recreating the vm instance."
    }
  }
}

resource "azurerm_managed_disk" "extra_disks" {
  count                         = length(var.extra_disks)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_access_policy         = var.network_access_policy
  disk_access_id                = data.azurerm_disk_access.disk_access.id
  public_network_access_enabled = var.public_network_access_enabled
  os_type                       = var.os_type

  name                 = var.extra_disks[count.index].name
  create_option        = var.extra_disks[count.index].create_option
  storage_account_type = var.extra_disks[count.index].storage_account_type
  disk_size_gb         = var.extra_disks[count.index].disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_extra_disk_attachments" {
  count              = length(azurerm_managed_disk.extra_disks)
  virtual_machine_id = azurerm_virtual_machine.vm_windows.id
  managed_disk_id    = azurerm_managed_disk.extra_disks[count.index].id
  lun                = count.index
  caching            = "ReadWrite"

  depends_on = [azurerm_managed_disk.extra_disks, azurerm_virtual_machine.vm_windows]
}

resource "azurerm_virtual_machine_extension" "extension" {
  count                       = length(var.vm_extensions)
  name                        = var.vm_extensions[count.index].name
  publisher                   = var.vm_extensions[count.index].publisher
  type                        = var.vm_extensions[count.index].type
  type_handler_version        = var.vm_extensions[count.index].type_handler_version
  virtual_machine_id          = azurerm_virtual_machine.vm_windows.id
  auto_upgrade_minor_version  = var.vm_extensions[count.index].auto_upgrade_minor_version
  automatic_upgrade_enabled   = var.vm_extensions[count.index].automatic_upgrade_enabled
  failure_suppression_enabled = var.vm_extensions[count.index].failure_suppression_enabled
  settings                    = var.vm_extensions[count.index].settings

  depends_on = [azurerm_virtual_machine.vm_windows, azurerm_managed_disk.extra_disks]
}

#resource "null_resource" "reset_password" {
#  triggers = {
#    id = azurerm_virtual_machine.vm_windows.id
#  }
#  provisioner "local-exec" {
#    command = <<EOT
#    subscriptionId = $ARM_SUBSCRIPTION_ID
#    tenantId = $ARM_TENANT_ID
#    clientId = $ARM_CLIENT_ID
#    secret = $ARM_CLIENT_SECRET
#
#    az login --service-principal --username $clientId --password $secret --tenant $tenantId
#    az account set --subscription ${var.subscription_id}
#    az vm user update --resource-group ${var.resource_group_name} --name ${format("az-vm-%s-%s-%s", var.vm_hostname, var.team_name, var.environment)} --username ${var.admin_username} --password ${var.admin_password}
#    EOT
#  }
#  depends_on = [azurerm_virtual_machine.vm_windows]
#}

# Use a null_resource to call az command to set disk access on the disk, only trigger when vm id is changed
#resource "null_resource" "update_disk_access" {
#  triggers = {
#    id = azurerm_virtual_machine.vm_windows.id
#  }
#
#  provisioner "local-exec" {
#    command = "az disk update --resource-group ${var.resource_group_name} --name az-disk-${var.vm_hostname}-${var.team_name}-${var.environment} --network-access-policy ${var.network_access_policy} --disk-access ${data.azurerm_disk_access.disk_access.id}"
#  }
#  depends_on = [ azurerm_virtual_machine.vm_windows ]
#}
