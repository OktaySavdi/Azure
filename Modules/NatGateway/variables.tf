variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "public_ip_name" {
  description = "Name of the public ip for outbound nat gateway"
  default     = ""
}

variable "allocation_method" {
  description = "Define the allocation method. It can be 'Static' or 'Dynamic'"
  default     = ""
}

variable "public_ip_sku" {
  description = "Skus for public ip can be 'Basic' or 'Standard'."
  default     = ""
}

variable "nat_gateway_name" {
  description = "Define nat gateway name."
  default     = ""
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
