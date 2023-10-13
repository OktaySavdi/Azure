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
  subscription_id        = "<subscription_ID>"
  tenant_id              = "<tenant_ID>"
  features {}
}
```
variables.tfvars
```hcl
location              = "westeurope"
vm_hostname           = "myserver"
vnet_subnet_id        = "/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Microsoft.Network/virtualNetworks/<virtual_network_name>/subnets/pblic-ip"
environment           = "test-01"
team_name             = "hce"
resource_group_name   = "<resource_group>"
zones                 = []
identity_type         = "SystemAssigned"
identity_ids          = []
enable_ssh_key        = true
ssh_key_values        = ["ssh-rsa AFG....Nzayl"]
data_sa_type          = "Standard_LRS"
data_disk_size_gb     = "20"
network_access_policy = "AllowPrivate"

tags = {
  CostCenter         = "EXA1001"
  DataClassification = "public"
  Owner              = "hce"
  Platform           = "shared-it"
  Environment        = "nonprod"
}

availability_set = {
  availability_set_enabled        = false
  as_platform_fault_domain_count  = 1
  as_platform_update_domain_count = 1
}

os_image_referance = {
  os_type         = "Linux"
  vm_os_simple    = "UbuntuServer"
  vm_os_publisher = "Canonical"
  vm_os_sku       = "18.04-LTS"
  vm_size         = "Standard_B2s"
}

#os_image_referance = {
#  os_type         = "Windows"
#  vm_os_simple    = "WindowsServer"
#  vm_os_publisher = "MicrosoftWindowsServer"
#  vm_os_sku       = "2016-Datacenter"
#  vm_size         = "Standard_B2s"
#}

disk_access_conf = {
  disk_access_name                = "example-access"
  disk_access_resource_group_name = "<resource_group>"
}

os_profile = {
  admin_username = "azureuser"
  admin_password = "P@$$w0rd1234!"
}

add_on = {
  delete_os_disk_on_termination    = true
  is_windows_image                 = false
  enable_ip_forwarding             = false
  nested_data_disks                = true
  delete_data_disks_on_termination = true
  enable_accelerated_networking    = false
}

extra_disks = [
  {
    disk_size_gb         = 5
    name                 = "extra1"
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
  },
  {
    disk_size_gb         = 5
    name                 = "extra2"
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
  }
]

vm_extensions = [
  {
    name                        = "hostname"
    publisher                   = "Microsoft.Azure.Extensions"                     # The publisher of the extension, available publishers can be found by using the Azure CLI. Changing this forces a new resource to be created.
    type                        = "CustomScript"                                   # The type of extension, available types for a publisher can be found using the Azure CLI.
    type_handler_version        = "2.0"                                            # Specifies the version of the extension to use, available versions can be found using the Azure CLI.
    settings                    = "{\"commandToExecute\": \"hostname && uptime\"}" # The settings passed to the extension, these are specified as a JSON object in a string.
    auto_upgrade_minor_version  = true                                             # Specifies if the platform deploys the latest minor version update to the type_handler_version specified.
    failure_suppression_enabled = false                                            # Should failures from the extension be suppressed? Possible values are true or false. Defaults to false
    automatic_upgrade_enabled   = false                                            # Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension?
  }
]
```
main.tf
```hcl
module "virtual_machine" {
  source                           = "git::https://myrepo.lan/modules.git//VirtualMachines?ref=3.65.0"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  environment                      = var.environment
  zones                            = var.zones
  extra_disks                      = var.extra_disks
  vm_extensions                    = var.vm_extensions
  team_name                        = var.team_name
  identity_ids                     = var.identity_ids
  vm_hostname                      = var.vm_hostname
  vm_os_publisher                  = var.os_image_referance.vm_os_publisher
  vm_os_simple                     = var.os_image_referance.vm_os_simple
  vm_os_sku                        = var.os_image_referance.vm_os_sku
  vm_size                          = var.os_image_referance.vm_size
  os_type                          = var.os_image_referance.os_type
  disk_access_name                 = var.disk_access_conf.disk_access_name
  disk_access_resource_group_name  = var.disk_access_conf.disk_access_resource_group_name
  as_platform_fault_domain_count   = var.availability_set.as_platform_fault_domain_count
  as_platform_update_domain_count  = var.availability_set.as_platform_update_domain_count
  availability_set_enabled         = var.availability_set.availability_set_enabled
  admin_username                   = var.os_profile.admin_username
  admin_password                   = var.os_profile.admin_password
  identity_type                    = var.identity_type
  vnet_subnet_id                   = var.vnet_subnet_id
  data_sa_type                     = var.data_sa_type
  network_access_policy            = var.network_access_policy
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

variable "os_image_referance" {
  description = "For each os_image_referance, create an object that contain fields"
  default     = {}
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
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.65, < 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.65, < 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_managed_disk.vm_data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_managed_disk.vm_extra_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine_data_disk_attachment.vm_data_disk_attachments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_resource_group.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure. | `string` | `""` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username of the VM that will be deployed. | `string` | `"azureuser"` | no |
| <a name="input_allocation_method"></a> [allocation\_method](#input\_allocation\_method) | Defines how an IP address is assigned. Options are Static or Dynamic. | `string` | `"Dynamic"` | no |
| <a name="input_as_platform_fault_domain_count"></a> [as\_platform\_fault\_domain\_count](#input\_as\_platform\_fault\_domain\_count) | (Optional) Specifies the number of fault domains that are used. Defaults to `2`. Changing this forces a new resource to be created. | `number` | `2` | no |
| <a name="input_as_platform_update_domain_count"></a> [as\_platform\_update\_domain\_count](#input\_as\_platform\_update\_domain\_count) | (Optional) Specifies the number of update domains that are used. Defaults to `2`. Changing this forces a new resource to be created. | `number` | `2` | no |
| <a name="input_availability_set_enabled"></a> [availability\_set\_enabled](#input\_availability\_set\_enabled) | (Optional) Enable or Disable availability set.  Default is `true` (enabled). | `bool` | `true` | no |
| <a name="input_boot_diagnostics"></a> [boot\_diagnostics](#input\_boot\_diagnostics) | (Optional) Enable or Disable boot diagnostics. | `bool` | `false` | no |
| <a name="input_boot_diagnostics_sa_type"></a> [boot\_diagnostics\_sa\_type](#input\_boot\_diagnostics\_sa\_type) | (Optional) Storage account type for boot diagnostics. | `string` | `"Standard_LRS"` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | The custom data to supply to the machine. This can be used as a cloud-init for Linux systems. | `string` | `""` | no |
| <a name="input_data_disk_size_gb"></a> [data\_disk\_size\_gb](#input\_data\_disk\_size\_gb) | Storage data disk size size. | `number` | `30` | no |
| <a name="input_data_sa_type"></a> [data\_sa\_type](#input\_data\_sa\_type) | Data Disk Storage Account type. | `string` | `"Standard_LRS"` | no |
| <a name="input_delete_data_disks_on_termination"></a> [delete\_data\_disks\_on\_termination](#input\_delete\_data\_disks\_on\_termination) | Delete data disks when machine is terminated. | `bool` | `false` | no |
| <a name="input_delete_os_disk_on_termination"></a> [delete\_os\_disk\_on\_termination](#input\_delete\_os\_disk\_on\_termination) | Delete OS disk when machine is terminated. | `bool` | `false` | no |
| <a name="input_enable_accelerated_networking"></a> [enable\_accelerated\_networking](#input\_enable\_accelerated\_networking) | (Optional) Enable accelerated networking on Network interface. | `bool` | `false` | no |
| <a name="input_enable_ip_forwarding"></a> [enable\_ip\_forwarding](#input\_enable\_ip\_forwarding) | (Optional) Should IP Forwarding be enabled? Defaults to `false`. | `bool` | `false` | no |
| <a name="input_enable_ssh_key"></a> [enable\_ssh\_key](#input\_enable\_ssh\_key) | (Optional) Enable ssh key authentication in Linux virtual Machine. | `bool` | `true` | no |
| <a name="input_external_boot_diagnostics_storage"></a> [external\_boot\_diagnostics\_storage](#input\_external\_boot\_diagnostics\_storage) | (Optional) The Storage Account's Blob Endpoint which should hold the virtual machine's diagnostic files. Set this argument would disable the creation of `azurerm_storage_account` resource. | <pre>object({<br>    uri = string<br>  })</pre> | `null` | no |
| <a name="input_extra_disks"></a> [extra\_disks](#input\_extra\_disks) | (Optional) List of extra data disks attached to each virtual machine. | <pre>list(object({<br>    name = string<br>    size = number<br>  }))</pre> | `[]` | no |
| <a name="input_extra_ssh_keys"></a> [extra\_ssh\_keys](#input\_extra\_ssh\_keys) | Same as ssh\_key, but allows for setting multiple public keys. Set your first key in ssh\_key, and the extras here. | `list(string)` | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_is_marketplace_image"></a> [is\_marketplace\_image](#input\_is\_marketplace\_image) | Boolean flag to notify when the image comes from the marketplace. | `bool` | `false` | no |
| <a name="input_is_windows_image"></a> [is\_windows\_image](#input\_is\_windows\_image) | Boolean flag to notify when the custom image is windows based. | `bool` | `false` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows\_Client and Windows\_Server | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) The location in which the resources will be created. | `string` | `null` | no |
| <a name="input_managed_data_disk_encryption_set_id"></a> [managed\_data\_disk\_encryption\_set\_id](#input\_managed\_data\_disk\_encryption\_set\_id) | (Optional) The disk encryption set ID for the managed data disk attached using the azurerm\_virtual\_machine\_data\_disk\_attachment resource. | `string` | `null` | no |
| <a name="input_name_template_availability_set"></a> [name\_template\_availability\_set](#input\_name\_template\_availability\_set) | The name template for the availability set. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`. All other text can be set as desired. | `string` | `"${vm_hostname}-avset"` | no |
| <a name="input_name_template_data_disk"></a> [name\_template\_data\_disk](#input\_name\_template\_data\_disk) | The name template for the data disks. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index', `${data_disk_number}` => 'data disk index'. All other text can be set as desired. | `string` | `"${vm_hostname}-datadisk-${host_number}-${data_disk_number}"` | no |
| <a name="input_name_template_extra_disk"></a> [name\_template\_extra\_disk](#input\_name\_template\_extra\_disk) | The name template for the extra disks. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index', `${extra_disk_name}` => 'name of extra disk'. All other text can be set as desired. | `string` | `"${vm_hostname}-extradisk-${host_number}-${extra_disk_name}"` | no |
| <a name="input_name_template_network_interface"></a> [name\_template\_network\_interface](#input\_name\_template\_network\_interface) | The name template for the network interface. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-nic-${host_number}"` | no |
| <a name="input_name_template_network_security_group"></a> [name\_template\_network\_security\_group](#input\_name\_template\_network\_security\_group) | The name template for the network security group. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`. All other text can be set as desired. | `string` | `"${vm_hostname}-nsg"` | no |
| <a name="input_name_template_public_ip"></a> [name\_template\_public\_ip](#input\_name\_template\_public\_ip) | The name template for the public ip. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${ip_number}` => 'public ip index'. All other text can be set as desired. | `string` | `"${vm_hostname}-pip-${ip_number}"` | no |
| <a name="input_name_template_vm_linux"></a> [name\_template\_vm\_linux](#input\_name\_template\_vm\_linux) | The name template for the Linux virtual machine. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-vmLinux-${host_number}"` | no |
| <a name="input_name_template_vm_linux_os_disk"></a> [name\_template\_vm\_linux\_os\_disk](#input\_name\_template\_vm\_linux\_os\_disk) | The name template for the Linux VM OS disk. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"osdisk-${vm_hostname}-${host_number}"` | no |
| <a name="input_name_template_vm_windows"></a> [name\_template\_vm\_windows](#input\_name\_template\_vm\_windows) | The name template for the Windows virtual machine. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-vmWindows-${host_number}"` | no |
| <a name="input_name_template_vm_windows_os_disk"></a> [name\_template\_vm\_windows\_os\_disk](#input\_name\_template\_vm\_windows\_os\_disk) | The name template for the Windows VM OS disk. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-osdisk-${host_number}"` | no |
| <a name="input_nb_data_disk"></a> [nb\_data\_disk](#input\_nb\_data\_disk) | (Optional) Number of the data disks attached to each virtual machine. | `number` | `0` | no |
| <a name="input_nb_instances"></a> [nb\_instances](#input\_nb\_instances) | Specify the number of vm instances. | `number` | `1` | no |
| <a name="input_nb_public_ip"></a> [nb\_public\_ip](#input\_nb\_public\_ip) | Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses. | `number` | `1` | no |
| <a name="input_nested_data_disks"></a> [nested\_data\_disks](#input\_nested\_data\_disks) | (Optional) When `true`, use nested data disks directly attached to the VM.  When `false`, use azurerm\_virtual\_machine\_data\_disk\_attachment resource to attach the data disks after the VM is created.  Default is `true`. | `bool` | `true` | no |
| <a name="input_network_security_group"></a> [network\_security\_group](#input\_network\_security\_group) | The network security group we'd like to bind with virtual machine. Set this variable will disable the creation of `azurerm_network_security_group` and `azurerm_network_security_rule` resources. | <pre>object({<br>    id = string<br>  })</pre> | `null` | no |
| <a name="input_os_profile_secrets"></a> [os\_profile\_secrets](#input\_os\_profile\_secrets) | Specifies a list of certificates to be installed on the VM, each list item is a map with the keys source\_vault\_id, certificate\_url and certificate\_store. | `list(map(string))` | `[]` | no |
| <a name="input_public_ip_dns"></a> [public\_ip\_dns](#input\_public\_ip\_dns) | Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb\_public\_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_public_ip_sku"></a> [public\_ip\_sku](#input\_public\_ip\_sku) | Defines the SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. | `string` | `"Basic"` | no |
| <a name="input_remote_port"></a> [remote\_port](#input\_remote\_port) | Remote tcp port to be used for access to the vms created via the nsg applied to the nics. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resources will be created. | `string` | n/a | yes |
| <a name="input_source_address_prefixes"></a> [source\_address\_prefixes](#input\_source\_address\_prefixes) | (Optional) List of source address prefixes allowed to access var.remote\_port. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash.e.g. c : /home/id\_rsa.pub. | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_ssh_key_values"></a> [ssh\_key\_values](#input\_ssh\_key\_values) | List of Public SSH Keys values to be used for ssh access to the VMs. | `list(string)` | `[]` | no |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | Defines the type of storage account to be created. Valid options are Standard\_LRS, Standard\_ZRS, Standard\_GRS, Standard\_RAGRS, Premium\_LRS. | `string` | `"Premium_LRS"` | no |
| <a name="input_storage_os_disk_size_gb"></a> [storage\_os\_disk\_size\_gb](#input\_storage\_os\_disk\_size\_gb) | (Optional) Specifies the size of the data disk in gigabytes. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |
| <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled) | Whether enable tracing tags that generated by BridgeCrew Yor. | `bool` | `false` | no |
| <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix) | Default prefix for generated tracing tags | `string` | `"avm_"` | no |
| <a name="input_vm_extension"></a> [vm\_extension](#input\_vm\_extension) | (Deprecated) This variable has been superseded by the `vm_extensions`. Argument to create `azurerm_virtual_machine_extension` resource, the argument descriptions could be found at [the document](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension). | <pre>object({<br>    name                        = string<br>    publisher                   = string<br>    type                        = string<br>    type_handler_version        = string<br>    auto_upgrade_minor_version  = optional(bool)<br>    automatic_upgrade_enabled   = optional(bool)<br>    failure_suppression_enabled = optional(bool, false)<br>    settings                    = optional(string)<br>    protected_settings          = optional(string)<br>    protected_settings_from_key_vault = optional(object({<br>      secret_url      = string<br>      source_vault_id = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_vm_extensions"></a> [vm\_extensions](#input\_vm\_extensions) | Argument to create `azurerm_virtual_machine_extension` resource, the argument descriptions could be found at [the document](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension). | <pre>set(object({<br>    name                        = string<br>    publisher                   = string<br>    type                        = string<br>    type_handler_version        = string<br>    auto_upgrade_minor_version  = optional(bool)<br>    automatic_upgrade_enabled   = optional(bool)<br>    failure_suppression_enabled = optional(bool, false)<br>    settings                    = optional(string)<br>    protected_settings          = optional(string)<br>    protected_settings_from_key_vault = optional(object({<br>      secret_url      = string<br>      source_vault_id = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_vm_hostname"></a> [vm\_hostname](#input\_vm\_hostname) | local name of the Virtual Machine. | `string` | `"myvm"` | no |
| <a name="input_vm_os_id"></a> [vm\_os\_id](#input\_vm\_os\_id) | The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is\_windows\_image = true for windows custom images. | `string` | `""` | no |
| <a name="input_vm_os_offer"></a> [vm\_os\_offer](#input\_vm\_os\_offer) | The name of the offer of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_publisher"></a> [vm\_os\_publisher](#input\_vm\_os\_publisher) | The name of the publisher of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_simple"></a> [vm\_os\_simple](#input\_vm\_os\_simple) | Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm\_os\_publisher, vm\_os\_offer, and vm\_os\_sku. | `string` | `""` | no |
| <a name="input_vm_os_sku"></a> [vm\_os\_sku](#input\_vm\_os\_sku) | The sku of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_version"></a> [vm\_os\_version](#input\_vm\_os\_version) | The version of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `"latest"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Specifies the size of the virtual machine. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | The subnet id of the virtual network where the virtual machines will reside. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | (Optional) The Availability Zone which the Virtual Machine should be allocated in, only one zone would be accepted. If set then this module won't create `azurerm_availability_set` resource. Changing this forces a new resource to be created. | `string` | `null` | no |
