# Azure virtual machine

## Notice on new alternative virtual machine module

This module was designed and implemented for AzureRM Provider v2.x, It's impossible to refactor this module from `azurerm_virtual_machine` to the modern version `azurerm_linux_virtual_machine` and `azurerm_windows_virtual_machine`. 

## Usage in Terraform

**providers.tf**
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.65.0"
    }
  }
 #  backend "azurerm" {
 #    resource_group_name  = "<your rg>" #change
 #    storage_account_name = "<your sa>" #change
 #    container_name       = "<your cn>" #change
 #    key                  = "/<your directoy>" #change
 #    subscription_id      = "<your storage account subscription>" #change
 #  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = "xxxx-xxxxx-xxxxx-xxxxx"
  features {}
}
```
**terraform.tfvars**
```hcl
location                      = "germanywestcentral"
subscription_id               = "xxxx-xxxxx-xxxxx-xxxxx"
vm_hostname                   = "myserver"
vnet_subnet_id                = "/subscriptions/<susbscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
environment                   = "test-01"
team_name                     = "hce"
resource_group_name           = "az-rg-hce-test-01"
zones                         = []
identity_type                 = "SystemAssigned"
identity_ids                  = []
enable_ssh_key                = true
ssh_key_values                = ["ssh-rsa AAAABscxxxxxx"]
data_sa_type                  = "Standard_LRS" #(Required) Possible values are Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, StandardSSD_LRS or UltraSSD_LRS
data_disk_size_gb             = "30"
network_access_policy         = "AllowPrivate" #(Required) Policy for accessing the disk via network. Allowed values are AllowPrivate, and DenyAll
public_network_access_enabled = false          #(Required) Whether it is allowed to access the disk via public network. Defaults to false

tags = {
  DataClassification = "internal"
  Owner              = "hce"
  Platform           = "it"
  Environment        = "nonprod"
}

availability_set = {
  availability_set_enabled        = false
  as_platform_fault_domain_count  = 1
  as_platform_update_domain_count = 1
}

### az vm image list --output table
os_image_referance = {
  os_type         = "Linux"
  vm_os_offer     = "0001-com-ubuntu-server-jammy"
  vm_os_publisher = "Canonical"
  vm_os_sku       = "22_04-lts-gen2"
  vm_size         = "Standard_B2s"
}

disk_access_conf = {
  disk_access_name                = "az-da-it-nonprod-01"
  disk_access_resource_group_name = "az-rg-it-network-nonprod-01"
}

os_profile = {
  admin_username = "azureuser"
  admin_password = "P@$$w0rd1234!"
}

add_on = {
  delete_os_disk_on_termination    = true  #(Optional) Should the OS Disk (either the Managed Disk / VHD Blob) be deleted when the Virtual Machine is destroyed? Defaults to false
  enable_ip_forwarding             = false #(Optional) Should IP Forwarding be enabled? Defaults to `false`
  nested_data_disks                = true  #(Optional) When `true`, use nested data disks directly attached to the VM.  When `false`, use azurerm_virtual_machine_data_disk_attachment resource to attach the data disks after the VM is created.  Default is `true`.
  delete_data_disks_on_termination = true  #(Optional) Delete data disks when machine is terminated
  enable_accelerated_networking    = false #(Optional) Enable accelerated networking on Network interface
}

extra_disks = [
  {
    disk_size_gb         = 5
    name                 = "extra1"
    storage_account_type = "Standard_LRS" #The type of storage to use for the managed disk. Possible values are Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, StandardSSD_LRS or UltraSSD_LRS
    create_option        = "Empty"
  } #,
  #{
  #  disk_size_gb         = 5
  #  name                 = "extra2"
  #  storage_account_type = "Standard_LRS"
  #  create_option        = "Empty"
  #}
]

vm_extensions = [
  #{
  #  name                        = "hostname"
  #  publisher                   = "Microsoft.Azure.Extensions"                     # The publisher of the extension, available publishers can be found by using the Azure CLI. Changing this forces a new resource to be created.
  #  type                        = "CustomScript"                                   # The type of extension, available types for a publisher can be found using the Azure CLI.
  #  type_handler_version        = "2.0"                                            # Specifies the version of the extension to use, available versions can be found using the Azure CLI.
  #  settings                    = "{\"commandToExecute\": \"hostname && uptime\"}" # The settings passed to the extension, these are specified as a JSON object in a string.
  #  auto_upgrade_minor_version  = true                                             # Specifies if the platform deploys the latest minor version update to the type_handler_version specified.
  #  failure_suppression_enabled = false                                            # Should failures from the extension be suppressed? Possible values are true or false. Defaults to false
  #  automatic_upgrade_enabled   = false                                            # Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension?
  #}
]
```
**main.tf**
```hcl
module "virtual_machine" {
  source                           = "git::https://<repo_address>/public/modules.git//VirtualMachines_Linux?ref=3.65.0"
  resource_group_name              = var.resource_group_name
  subscription_id                  = var.subscription_id
  location                         = var.location
  environment                      = var.environment
  zones                            = var.zones
  extra_disks                      = var.extra_disks
  vm_extensions                    = var.vm_extensions
  team_name                        = var.team_name
  identity_ids                     = var.identity_ids
  vm_hostname                      = var.vm_hostname
  vm_os_publisher                  = var.os_image_referance["vm_os_publisher"]
  vm_os_offer                      = var.os_image_referance["vm_os_offer"]
  vm_os_sku                        = var.os_image_referance["vm_os_sku"]
  vm_size                          = var.os_image_referance["vm_size"]
  os_type                          = var.os_image_referance["os_type"]
  disk_access_name                 = var.disk_access_conf["disk_access_name"]
  disk_access_resource_group_name  = var.disk_access_conf["disk_access_resource_group_name"]
  as_platform_fault_domain_count   = var.availability_set["as_platform_fault_domain_count"]
  as_platform_update_domain_count  = var.availability_set["as_platform_update_domain_count"]
  availability_set_enabled         = var.availability_set["availability_set_enabled"]
  admin_username                   = var.os_profile["admin_username"]
  admin_password                   = var.os_profile["admin_password"]
  identity_type                    = var.identity_type
  vnet_subnet_id                   = var.vnet_subnet_id
  data_sa_type                     = var.data_sa_type
  network_access_policy            = var.network_access_policy
  public_network_access_enabled    = var.public_network_access_enabled
  delete_os_disk_on_termination    = var.add_on.delete_os_disk_on_termination
  data_disk_size_gb                = var.data_disk_size_gb
  enable_ip_forwarding             = var.add_on.enable_ip_forwarding
  nested_data_disks                = var.add_on.nested_data_disks
  enable_ssh_key                   = var.enable_ssh_key
  ssh_key_values                   = var.ssh_key_values
  delete_data_disks_on_termination = var.add_on.delete_data_disks_on_termination
  enable_accelerated_networking    = var.add_on.enable_accelerated_networking
  tags                             = var.tags
}
```
**variables.tf**
```
variable "location" {
  description = "Specifies the Azure Region where the Virtual Machine exists. Changing this forces a new resource to be created"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Specifies the name of the Resource Group in which the Virtual Machine should exist. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "vm_hostname" {
  description = "Specifies the name of the Virtual Machine. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  default     = []
}

variable "environment" {
  description = "Environment name. Possible values are stg and prod"
  type        = string
  default     = ""
}

variable "team_name" {
  description = "team name. Please specify your team name"
  type        = string
  default     = ""
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = string
  default     = ""
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type."
  type        = string
  default     = ""
}

variable "zones" {
  description = "The Availability Zone which the Virtual Machine should be allocated in, only one zone would be accepted. If set then this module won't create azurerm_availability_set resource. Changing this forces a new resource to be created."
  default     = []
}

variable "ssh_key_values" {
  description = "List of Public SSH Keys values to be used for ssh access to the VMs."
  type        = list(string)
  default     = []
}

variable "network_access_policy" {
  description = "Policy for accessing the disk via network."
  type        = string
  default     = ""
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = number
}

variable "enable_ssh_key" {
  description = "Enable ssh key authentication in Linux virtual Machine."
  type        = string
  default     = ""
}

variable "availability_set" {
  description = "For each availability_set, create an object that contain fields"
  default     = {}
}

variable "os_profile" {
  description = "For each os_profile, create an object that contain fields"
  default     = {}
}

variable "add_on" {
  description = "For each add_on, create an object that contain fields"
  default     = {}
}

variable "disk_access_conf" {
  description = "For each disk_access_conf, create an object that contain fields"
  default     = {}
}

variable "extra_disks" {
  description = "For each extra_disks, create an object that contain fields"
  default     = []
}

variable "vm_extensions" {
  description = "For each vm_extensions, create an object that contain fields"
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "public_network_access_enabled" {
  description = "Whether it is allowed to access the disk via public network. Defaults to true"
  type        = string
  default     = ""
}

variable "os_image_referance" {
  description = "An example variable"
  default     = {}
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = ""
  sensitive   = true
}

variable "subscription_id" {
  description = "(Optional) Specifies the subscription_id"
  type        = string
  default     = ""
}
```
**outputs.tf**
```hcl
output "os_disk_name" {
  value = module.virtual_machine.os_disk_name
}
output "os_disk_gallery_image_reference_id" {
  value = module.virtual_machine.os_disk_gallery_image_reference_id
}
output "os_disk_size_gb" {
  value = module.virtual_machine.os_disk_size_gb
}
output "os_disk_network_access_policy" {
  value = module.virtual_machine.os_disk_network_access_policy
}
output "os_disk_access_id" {
  value = module.virtual_machine.os_disk_access_id
}
output "os_disk_public_network_access_enabled" {
  value = module.virtual_machine.os_disk_public_network_access_enabled
}
output "network_interface_name" {
  value = module.virtual_machine.network_interface_name
}
output "virtual_machine_name" {
  value = module.virtual_machine.virtual_machine_name
}
output "virtual_machine_location" {
  value = module.virtual_machine.virtual_machine_location
}
output "virtual_machine_vm_size" {
  value = module.virtual_machine.virtual_machine_vm_size
}
output "extra_disks_name" {
  value = module.virtual_machine.extra_disks_name
}
output "virtual_machine_extension_name" {
  value = module.virtual_machine.virtual_machine_extension_name
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.65.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.vm](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/resources/availability_set) | resource |
| [azurerm_managed_disk.extra_disks](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/resources/managed_disk) | resource |
| [azurerm_managed_disk.os_disk](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.vm](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine.vm_linux](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine_data_disk_attachment.vm_extra_disk_attachments](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.extension](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/resources/virtual_machine_extension) | resource |
| [null_resource.reset_password](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_disk_access.disk_access](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/data-sources/disk_access) | data source |
| [azurerm_platform_image.vm](https://registry.terraform.io/providers/hashicorp/azurerm/3.65.0/docs/data-sources/platform_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_on"></a> [add\_on](#input\_add\_on) | An example variable | `map` | `{}` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure. | `string` | `""` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username of the VM that will be deployed. | `string` | n/a | yes |
| <a name="input_as_platform_fault_domain_count"></a> [as\_platform\_fault\_domain\_count](#input\_as\_platform\_fault\_domain\_count) | (Optional) Specifies the number of fault domains that are used. Defaults to `2`. Changing this forces a new resource to be created. | `number` | n/a | yes |
| <a name="input_as_platform_update_domain_count"></a> [as\_platform\_update\_domain\_count](#input\_as\_platform\_update\_domain\_count) | (Optional) Specifies the number of update domains that are used. Defaults to `2`. Changing this forces a new resource to be created. | `number` | n/a | yes |
| <a name="input_availability_set"></a> [availability\_set](#input\_availability\_set) | An example variable | `map` | `{}` | no |
| <a name="input_availability_set_enabled"></a> [availability\_set\_enabled](#input\_availability\_set\_enabled) | (Optional) Enable or Disable availability set.  Default is `true` (enabled). | `bool` | n/a | yes |
| <a name="input_data_disk_size_gb"></a> [data\_disk\_size\_gb](#input\_data\_disk\_size\_gb) | Storage data disk size size. | `number` | n/a | yes |
| <a name="input_data_sa_type"></a> [data\_sa\_type](#input\_data\_sa\_type) | Data Disk Storage Account type. | `string` | n/a | yes |
| <a name="input_delete_data_disks_on_termination"></a> [delete\_data\_disks\_on\_termination](#input\_delete\_data\_disks\_on\_termination) | Delete data disks when machine is terminated. | `bool` | n/a | yes |
| <a name="input_delete_os_disk_on_termination"></a> [delete\_os\_disk\_on\_termination](#input\_delete\_os\_disk\_on\_termination) | Delete OS disk when machine is terminated. | `bool` | n/a | yes |
| <a name="input_disk_access_conf"></a> [disk\_access\_conf](#input\_disk\_access\_conf) | An example variable | `map` | `{}` | no |
| <a name="input_disk_access_name"></a> [disk\_access\_name](#input\_disk\_access\_name) | (Required) The name of this Disk Access. | `string` | n/a | yes |
| <a name="input_disk_access_resource_group_name"></a> [disk\_access\_resource\_group\_name](#input\_disk\_access\_resource\_group\_name) | (Required) The name of the Resource Group where the Disk Access exists. | `string` | n/a | yes |
| <a name="input_enable_accelerated_networking"></a> [enable\_accelerated\_networking](#input\_enable\_accelerated\_networking) | (Optional) Enable accelerated networking on Network interface. | `bool` | n/a | yes |
| <a name="input_enable_ip_forwarding"></a> [enable\_ip\_forwarding](#input\_enable\_ip\_forwarding) | (Optional) Should IP Forwarding be enabled? Defaults to `false`. | `bool` | n/a | yes |
| <a name="input_enable_ssh_key"></a> [enable\_ssh\_key](#input\_enable\_ssh\_key) | (Optional) Enable ssh key authentication in Linux virtual Machine. | `bool` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name. Possible values are stg and prod | `string` | n/a | yes |
| <a name="input_extra_disks"></a> [extra\_disks](#input\_extra\_disks) | (Optional) List of extra data disks attached to each virtual machine. | `list` | `[]` | no |
| <a name="input_extra_ssh_keys"></a> [extra\_ssh\_keys](#input\_extra\_ssh\_keys) | Same as ssh\_key, but allows for setting multiple public keys. Set your first key in ssh\_key, and the extras here. | `list(string)` | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Optional) The location in which the resources will be created. | `string` | n/a | yes |
| <a name="input_nested_data_disks"></a> [nested\_data\_disks](#input\_nested\_data\_disks) | (Optional) When `true`, use nested data disks directly attached to the VM.  When `false`, use azurerm\_virtual\_machine\_data\_disk\_attachment resource to attach the data disks after the VM is created.  Default is `true`. | `bool` | n/a | yes |
| <a name="input_network_access_policy"></a> [network\_access\_policy](#input\_network\_access\_policy) | Policy for accessing the disk via network. | `string` | n/a | yes |
| <a name="input_os_image_referance"></a> [os\_image\_referance](#input\_os\_image\_referance) | An example variable | `map` | `{}` | no |
| <a name="input_os_profile"></a> [os\_profile](#input\_os\_profile) | An example variable | `map` | `{}` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | (required) Operating System. Possible values Linux or Windows | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether it is allowed to access the disk via public network. Defaults to true | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resources will be created. | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash.e.g. c : /home/id\_rsa.pub. | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_ssh_key_values"></a> [ssh\_key\_values](#input\_ssh\_key\_values) | List of Public SSH Keys values to be used for ssh access to the VMs. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | team name. Please specify your team name | `string` | n/a | yes |
| <a name="input_virtual_machines"></a> [virtual\_machines](#input\_virtual\_machines) | For each virtual\_machines, create an object that contain fields | `map` | `{}` | no |
| <a name="input_vm_extensions"></a> [vm\_extensions](#input\_vm\_extensions) | (Optional) List of extra data disks attached to each virtual machine. | `list` | `[]` | no |
| <a name="input_vm_hostname"></a> [vm\_hostname](#input\_vm\_hostname) | local name of the Virtual Machine. | `string` | `"myvm"` | no |
| <a name="input_vm_os_offer"></a> [vm\_os\_offer](#input\_vm\_os\_offer) | Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm\_os\_publisher, vm\_os\_offer, and vm\_os\_sku. | `string` | `""` | no |
| <a name="input_vm_os_publisher"></a> [vm\_os\_publisher](#input\_vm\_os\_publisher) | The name of the publisher of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_sku"></a> [vm\_os\_sku](#input\_vm\_os\_sku) | The sku of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_version"></a> [vm\_os\_version](#input\_vm\_os\_version) | The version of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `"latest"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Specifies the size of the virtual machine. | `string` | n/a | yes |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | The subnet id of the virtual network where the virtual machines will reside. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | (Optional) The Availability Zone which the Virtual Machine should be allocated in, only one zone would be accepted. If set then this module won't create `azurerm_availability_set` resource. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | An example variable | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_extra_disks_name"></a> [extra\_disks\_name](#output\_extra\_disks\_name) | n/a |
| <a name="output_network_interface_name"></a> [network\_interface\_name](#output\_network\_interface\_name) | The name of the network\_interface\_name |
| <a name="output_os_disk_access_id"></a> [os\_disk\_access\_id](#output\_os\_disk\_access\_id) | The name of the os\_disk\_access\_id |
| <a name="output_os_disk_gallery_image_reference_id"></a> [os\_disk\_gallery\_image\_reference\_id](#output\_os\_disk\_gallery\_image\_reference\_id) | The name of the os\_disk\_gallery\_image\_reference\_id |
| <a name="output_os_disk_name"></a> [os\_disk\_name](#output\_os\_disk\_name) | The name of the disk name. |
| <a name="output_os_disk_network_access_policy"></a> [os\_disk\_network\_access\_policy](#output\_os\_disk\_network\_access\_policy) | The name of the os\_disk\_network\_access\_policy |
| <a name="output_os_disk_public_network_access_enabled"></a> [os\_disk\_public\_network\_access\_enabled](#output\_os\_disk\_public\_network\_access\_enabled) | The name of the os\_disk\_public\_network\_access\_enabled |
| <a name="output_os_disk_size_gb"></a> [os\_disk\_size\_gb](#output\_os\_disk\_size\_gb) | The name of the os\_disk\_size\_gb |
| <a name="output_virtual_machine_extension_name"></a> [virtual\_machine\_extension\_name](#output\_virtual\_machine\_extension\_name) | The name of the virtual\_machine\_extension |
| <a name="output_virtual_machine_location"></a> [virtual\_machine\_location](#output\_virtual\_machine\_location) | The name of the virtual\_machine\_location |
| <a name="output_virtual_machine_name"></a> [virtual\_machine\_name](#output\_virtual\_machine\_name) | The name of the virtual\_machine\_name |
| <a name="output_virtual_machine_vm_size"></a> [virtual\_machine\_vm\_size](#output\_virtual\_machine\_vm\_size) | The name of the vm\_size |
