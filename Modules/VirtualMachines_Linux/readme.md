# Azure virtual machine

**providers.tf**
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.97.1"
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
subscription_id               = "xxxx-xxxxx-xxxx-xxxxx-xxxxx"
vm_hostname                   = "mytest01" # max 15 characters
resource_group_name           = "az-rg-hce-test-01"
team_name                     = "hce"
environment                   = "test-01"
admin_username                = "azureuser"
admin_password                = "P@$$w0rd1234!"
disable_password_authentication = false
identity_type                 = "SystemAssigned"
identity_ids                  = []
size                          = "Standard_B2s"
source_image_id               = "/subscriptions/<sub_id>/resourceGroups/<rg_name>/providers/Microsoft.Compute/galleries/<gallery_name>/images/<image_name>/versions/<version>"
vnet_subnet_id                = "/subscriptions/<sub_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
ssh_key_values                = ["ssh-rsa AAAAiuyfkjbdsfieywjdlsffejdbECMrDoS02Qsjsuosjshngiueravnyoq5"]
data_sa_type                  = "Standard_LRS" #(Required) Possible values are Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, StandardSSD_LRS or UltraSSD_LRS
data_disk_size_gb             = "80"
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
### Put null if you specified source_image_id
os_image_referance = {
  vm_os_offer     = null #"0001-com-ubuntu-server-jammy"
  vm_os_publisher = null #"Canonical"
  vm_os_sku       = null #"22_04-lts-gen2"
  version         = null #"latest"
}

disk_access_conf = {
  disk_access_name                = "az-da-it-nonprod-01"
  disk_access_resource_group_name = "az-rg-it-network-nonprod-01"
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
  source                           = "git::https://myrepo.lan/modules.git//VirtualMachines_Linux?ref=v3.97.1"
  resource_group_name              = var.resource_group_name
  subscription_id                  = var.subscription_id
  location                         = var.location
  environment                      = var.environment
  extra_disks                      = var.extra_disks
  vm_extensions                    = var.vm_extensions
  team_name                        = var.team_name
  identity_ids                     = var.identity_ids
  vm_hostname                      = var.vm_hostname
  source_image_id                  = var.source_image_id
  size                             = var.size
  disable_password_authentication  = var.disable_password_authentication
  vm_os_publisher                  = var.os_image_referance["vm_os_publisher"]
  vm_os_offer                      = var.os_image_referance["vm_os_offer"]
  vm_os_sku                        = var.os_image_referance["vm_os_sku"]
  vm_os_version                    = var.os_image_referance["version"]
  disk_access_name                 = var.disk_access_conf["disk_access_name"]
  disk_access_resource_group_name  = var.disk_access_conf["disk_access_resource_group_name"]
  as_platform_fault_domain_count   = var.availability_set["as_platform_fault_domain_count"]
  as_platform_update_domain_count  = var.availability_set["as_platform_update_domain_count"]
  availability_set_enabled         = var.availability_set["availability_set_enabled"]
  admin_username                   = var.admin_username
  admin_password                   = var.admin_password
  identity_type                    = var.identity_type
  vnet_subnet_id                   = var.vnet_subnet_id
  data_sa_type                     = var.data_sa_type
  network_access_policy            = var.network_access_policy
  public_network_access_enabled    = var.public_network_access_enabled
  delete_os_disk_on_termination    = var.add_on["delete_os_disk_on_termination"]
  data_disk_size_gb                = var.data_disk_size_gb
  enable_ip_forwarding             = var.add_on["enable_ip_forwarding"]
  nested_data_disks                = var.add_on["nested_data_disks"]
  ssh_key_values                   = var.ssh_key_values  
  delete_data_disks_on_termination = var.add_on["delete_data_disks_on_termination"]
  enable_accelerated_networking    = var.add_on["enable_accelerated_networking"]
  tags                             = var.tags
}
```
**variables.tf**
```hcl
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

variable "network_access_policy" {
  description = "Policy for accessing the disk via network."
  type        = string
  default     = ""
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = number
}

variable "size" {
  type        = string
  description = "Specifies the size of the virtual machine."
}

variable "availability_set" {
  description = "For each availability_set, create an object that contain fields"
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

variable "subscription_id" {
  description = "(Optional) Specifies the subscription_id"
  type        = string
  default     = "xxx-xxx-xxx-xxx-xxx"
}

variable "admin_password" {
  description = " (Required) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = " (Required) The username of the local administrator used for the Virtual Machine. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "source_image_id" {
  description = "(Optional) The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created. Possible Image ID types include Image IDs, Shared Image IDs, Shared Image Version IDs, Community Gallery Image IDs, Community Gallery Image Version IDs, Shared Gallery Image IDs and Shared Gallery Image Version IDs"
  type        = string
}

variable "write_accelerator_enabled" {
  description = "(Optional) Are automatic updates enabled on this Virtual Machine? Defaults to false."
  type        = bool
  default     = false
}

variable "ssh_key_values" {
  description = "List of Public SSH Keys values to be used for ssh access to the VMs."
  type        = list(string)
  default     = []
}

variable "disable_password_authentication" {
  description = "(Optional) Should Password Authentication be disabled on this Virtual Machine? Defaults to true. Changing this forces a new resource to be created."
  type        = bool
}

variable "os_image_referance" {
  description = "An example variable"
  default     = {}
}
```
**outputs.tf**
```hcl
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.97.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_on"></a> [add\_on](#input\_add\_on) | For each add\_on, create an object that contain fields | `map` | `{}` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Required) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Required) The username of the local administrator used for the Virtual Machine. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_availability_set"></a> [availability\_set](#input\_availability\_set) | For each availability\_set, create an object that contain fields | `map` | `{}` | no |
| <a name="input_data_disk_size_gb"></a> [data\_disk\_size\_gb](#input\_data\_disk\_size\_gb) | Storage data disk size size. | `number` | n/a | yes |
| <a name="input_data_sa_type"></a> [data\_sa\_type](#input\_data\_sa\_type) | Data Disk Storage Account type. | `string` | `""` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | (Optional) Should Password Authentication be disabled on this Virtual Machine? Defaults to true. Changing this forces a new resource to be created. | `bool` | n/a | yes |
| <a name="input_disk_access_conf"></a> [disk\_access\_conf](#input\_disk\_access\_conf) | For each disk\_access\_conf, create an object that contain fields | `map` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name. Possible values are stg and prod | `string` | `""` | no |
| <a name="input_extra_disks"></a> [extra\_disks](#input\_extra\_disks) | For each extra\_disks, create an object that contain fields | `list` | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the Azure Region where the Virtual Machine exists. Changing this forces a new resource to be created | `string` | `""` | no |
| <a name="input_network_access_policy"></a> [network\_access\_policy](#input\_network\_access\_policy) | Policy for accessing the disk via network. | `string` | `""` | no |
| <a name="input_os_image_referance"></a> [os\_image\_referance](#input\_os\_image\_referance) | An example variable | `map` | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether it is allowed to access the disk via public network. Defaults to true | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the name of the Resource Group in which the Virtual Machine should exist. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_size"></a> [size](#input\_size) | Specifies the size of the virtual machine. | `string` | n/a | yes |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | (Optional) The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created. Possible Image ID types include Image IDs, Shared Image IDs, Shared Image Version IDs, Community Gallery Image IDs, Community Gallery Image Version IDs, Shared Gallery Image IDs and Shared Gallery Image Version IDs | `string` | n/a | yes |
| <a name="input_ssh_key_values"></a> [ssh\_key\_values](#input\_ssh\_key\_values) | List of Public SSH Keys values to be used for ssh access to the VMs. | `list(string)` | `[]` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Optional) Specifies the subscription\_id | `string` | `"xxx-xxx-xxx-xxx-xxx"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map` | `{}` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | team name. Please specify your team name | `string` | `""` | no |
| <a name="input_vm_extensions"></a> [vm\_extensions](#input\_vm\_extensions) | For each vm\_extensions, create an object that contain fields | `list` | `[]` | no |
| <a name="input_vm_hostname"></a> [vm\_hostname](#input\_vm\_hostname) | Specifies the name of the Virtual Machine. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | The subnet id of the virtual network where the virtual machines will reside. | `string` | `""` | no |
| <a name="input_write_accelerator_enabled"></a> [write\_accelerator\_enabled](#input\_write\_accelerator\_enabled) | (Optional) Are automatic updates enabled on this Virtual Machine? Defaults to false. | `bool` | `false` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The Availability Zone which the Virtual Machine should be allocated in, only one zone would be accepted. If set then this module won't create azurerm\_availability\_set resource. Changing this forces a new resource to be created. | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_extra_disks_name"></a> [extra\_disks\_name](#output\_extra\_disks\_name) | n/a |
| <a name="output_network_interface_name"></a> [network\_interface\_name](#output\_network\_interface\_name) | n/a |
| <a name="output_virtual_machine_extension_name"></a> [virtual\_machine\_extension\_name](#output\_virtual\_machine\_extension\_name) | n/a |
| <a name="output_virtual_machine_location"></a> [virtual\_machine\_location](#output\_virtual\_machine\_location) | n/a |
| <a name="output_virtual_machine_name"></a> [virtual\_machine\_name](#output\_virtual\_machine\_name) | n/a |
| <a name="output_virtual_machine_vm_size"></a> [virtual\_machine\_vm\_size](#output\_virtual\_machine\_vm\_size) | n/a |
