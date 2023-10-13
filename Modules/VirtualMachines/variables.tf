variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}

variable "vnet_subnet_id" {
  type        = string
  description = "The subnet id of the virtual network where the virtual machines will reside."
}

variable "admin_password" {
  type        = string
  default     = ""
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
}

variable "admin_username" {
  type        = string
  description = "The admin username of the VM that will be deployed."
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

variable "vm_os_publisher" {
  type        = string
  default     = ""
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
}

variable "vm_os_simple" {
  type        = string
  default     = ""
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
}

variable "vm_os_sku" {
  type        = string
  default     = ""
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
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

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
}

variable "extra_ssh_keys" {
  type        = list(string)
  default     = []
  description = "Same as ssh_key, but allows for setting multiple public keys. Set your first key in ssh_key, and the extras here."
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

variable "ssh_key" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash.e.g. c : /home/id_rsa.pub."
}

variable "ssh_key_values" {
  type        = list(string)
  default     = []
  description = "List of Public SSH Keys values to be used for ssh access to the VMs."
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

variable "vm_size" {
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

variable "os_type" {
  type        = string
  description = "(required) Operating System. Possible values Linux or Windows"
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

variable "os_profile" {
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

variable "zones" {
  description = "An example variable"
  default     = []
}

variable "vm_extensions" {
  description = "(Optional) List of extra data disks attached to each virtual machine."
  default     = []
}
