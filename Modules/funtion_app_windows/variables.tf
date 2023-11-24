variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "westeurope"
}

variable "vnet_name" {
  description = "Name of Azure Virtual Network"
  default     = ""
}

variable "subnet_name" {
  description = "For each subnet, create an object that contain fields"
  default     = {}
}

variable "network_resource_group_name" {
  description = "network resource group name"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "storage_account_name" {
  description = "storage account name"
  default     = ""
}


variable "storage_primary_access_key" {
  description = "storage account primary access key"
  default     = ""
}

variable "service_plan_name" {
  description = "Service plan name"
  default     = ""
}

variable "sku_name" {
  description = "Service plan name"
  default     = ""
}

variable "function_name" {
  description = "Service plan name"
  default     = ""
}

variable "site_config" {
  description = "For each subnet, create an object that contain fields"
  default     = {}
}
