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

variable "storage_account_name" {
  description = "The name of the azure storage account"
  default     = ""
  type        = string
}

variable "min_tls_version" {
  description = "A min tls version - Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2"
  default     = ""
  type        = string
}

variable "account_replication_type" {
  description = "Account Replication type - Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
  default     = ""
  type        = string
}

variable "account_kind" {
  description = "The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = ""
  type        = string
}

variable "account_tier" {
  description = "The SKUs supported by Microsoft Azure Storage. Valid options are Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, Standard_LRS, Standard_RAGRS, Standard_RAGZRS, Standard_ZRS"
  default     = ""
  type        = string
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public. Defaults to true"
  type        = bool
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
  default     = ""
  type        = string
}

variable "private_endpoint_name" {
  description = "Azure private endpoint name"
  default     = ""
  type        = string
}

variable "location_private_rg" {
  description = "Azure private endpoint resource group name"
  default     = ""
  type        = string
}

variable "location_private_rg_name" {
  description = "Azure private endpoint resource group location"
  default     = ""
  type        = string
}

variable "subnet_id" {
  description = "The subnet id for routable network"
  default     = ""
  type        = string
}

variable "subresource_names" {
  description = "The subnet id for routable network"
  default     = []
  type        = list(any)
}

variable "private_dns_zone_group_name" {
  description = "The privtae dns group name"
  default     = ""
  type        = string
}

variable "private_dns_zone_ids" {
  description = "The privtae dns zone id"
  default     = []
  type        = list(any)
}

variable "enable_advanced_threat_protection" {
  description = "To enable advanced threat protection set argument to `true`"
  type        = bool
}

variable "containers_list" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, access_type = string }))
  default     = []
}

variable "file_shares" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, quota = number }))
  default     = []
}

variable "queues" {
  description = "List of storages queues"
  type        = list(string)
  default     = []
}

variable "tables" {
  description = "List of storage tables."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}