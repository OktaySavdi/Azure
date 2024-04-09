variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}

variable "vnet_subnet_id" {
  type        = string
  description = "The subnet id of the virtual network where the virtual machines will reside."
}

variable "as_platform_fault_domain_count" {
  type        = number
  description = "(Optional) Specifies the number of fault domains that are used. Defaults to `2`. Changing this forces a new resource to be created."
}

variable "as_platform_update_domain_count" {
  type        = number
  description = "(Optional) Specifies the number of update domains that are used. Defaults to `2`. Changing this forces a new resource to be created."
}

variable "availability_set_enabled" {
  type        = bool
  description = "(Optional) Enable or Disable availability set.  Default is `true` (enabled)."
  nullable    = false
}

variable "vm_os_version" {
  type        = string
  default     = "latest"
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
}

variable "data_disk_size_gb" {
  type        = number
  description = "Storage data disk size size."
}

variable "data_sa_type" {
  type        = string
  description = "Data Disk Storage Account type."
}

variable "delete_data_disks_on_termination" {
  type        = bool
  description = "Delete data disks when machine is terminated."
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete OS disk when machine is terminated."
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface."
}

variable "enable_ip_forwarding" {
  type        = bool
  description = "(Optional) Should IP Forwarding be enabled? Defaults to `false`."
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
}

variable "identity_type" {
  type        = string
  description = "The Managed Service Identity Type of this Virtual Machine."
}

variable "location" {
  type        = string
  description = "(Optional) The location in which the resources will be created."
}

variable "nested_data_disks" {
  type        = bool
  description = "(Optional) When `true`, use nested data disks directly attached to the VM.  When `false`, use azurerm_virtual_machine_data_disk_attachment resource to attach the data disks after the VM is created.  Default is `true`."
  nullable    = false
}

variable "tags" {
  type = map(string)
  default = {
    source = "terraform"
  }
  description = "A map of the tags to use on the resources that are deployed with this module."
}

variable "vm_hostname" {
  description = "local name of the Virtual Machine."
  type        = string
  default     = "myvm"
}

variable "size" {
  type        = string
  description = "Specifies the size of the virtual machine."
}

variable "zone" {
  type        = string
  default     = null
  description = "(Optional) The Availability Zone which the Virtual Machine should be allocated in, only one zone would be accepted. If set then this module won't create `azurerm_availability_set` resource. Changing this forces a new resource to be created."
}

variable "team_name" {
  type        = string
  description = "team name. Please specify your team name"
}

variable "environment" {
  description = "Environment name. Possible values are stg and prod"
  type        = string
}

variable "network_access_policy" {
  description = "Policy for accessing the disk via network."
  type        = string
}

variable "disk_access_name" {
  description = "(Required) The name of this Disk Access."
  type        = string
}

variable "disk_access_resource_group_name" {
  description = "(Required) The name of the Resource Group where the Disk Access exists."
  type        = string
}

variable "virtual_machines" {
  description = "For each virtual_machines, create an object that contain fields"
  default     = {}
}

variable "os_image_referance" {
  description = "An example variable"
  default     = {}
}

variable "availability_set" {
  description = "An example variable"
  default     = {}
}

variable "add_on" {
  description = "An example variable"
  default     = {}
}

variable "disk_access_conf" {
  description = "An example variable"
  default     = {}
}

variable "extra_disks" {
  description = "(Optional) List of extra data disks attached to each virtual machine."
  default     = []
}

variable "vm_os_publisher" {
  type        = string
  default     = ""
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
}

variable "vm_os_offer" {
  type        = string
  default     = ""
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
}

variable "vm_os_sku" {
  type        = string
  default     = ""
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
}

variable "vm_extensions" {
  description = "(Optional) List of extra data disks attached to each virtual machine."
  default     = []
}

variable "public_network_access_enabled" {
  description = "Whether it is allowed to access the disk via public network. Defaults to true"
  type        = string
}

variable "provision_vm_agent" {
  description = "(Optional) Should the Azure Virtual Machine Guest Agent be installed on this Virtual Machine? Defaults to false"
  type        = bool
  default     = false
}

variable "enable_automatic_upgrades" {
  description = "(Optional) Are automatic updates enabled on this Virtual Machine? Defaults to false."
  type        = bool
  default     = false
}

variable "timezone" {
  description = "(Optional) Specifies the time zone of the virtual machine, the possible values are defined here. Changing this forces a new resource to be created."
  type        = string
  default     = "W. Europe Standard Time"
}

variable "subscription_id" {
  description = "(Optional) Specifies the subscription_id"
  type        = string
  default     = "xxx-xxx-xxx-xxx-xxx"
}

variable "admin_password" {
  description = " (Required) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created."
  type        = string
}

variable "admin_username" {
  description = " (Required) The username of the local administrator used for the Virtual Machine. Changing this forces a new resource to be created."
  type        = string
}

variable "source_image_id" {
  description = "(Optional) The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created. Possible Image ID types include Image IDs, Shared Image IDs, Shared Image Version IDs, Community Gallery Image IDs, Community Gallery Image Version IDs, Shared Gallery Image IDs and Shared Gallery Image Version IDs"
  type        = string
}

variable "write_accelerator_enabled" {
  description = "(Optional) Are automatic updates enabled on this Virtual Machine? Defaults to false."
  type        = bool
}
