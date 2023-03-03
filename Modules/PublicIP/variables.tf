variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
  type        = string
}

variable "public_ip" {
  description = "The list of role public_ip to this service principal"
  type = list(object({
    name              = string
    allocation_method = string #Defines the allocation method for this IP address. Possible values are Static or Dynamic
    sku               = string #The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}