# Storage Account Module

Terraform module for Storage Account

## Module Usage

**main.tf**
```hcl
data "azurerm_private_dns_zone" "pe_dns" {
  provider            = azurerm.pe
  name                = var.azurerm_private_dns_zone
  resource_group_name = var.shared_private_dns_zone_resource_group_name
}

module "storage" {
  source                          = "git::https://<git_address>/hce-public/modules.git//StorageAccount"
  resource_group_name             = "az-rg-hce-test-01"
  storage_account_name            = "azstgtithcenonprod01"
  location                        = var.private_endpoint_location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = true #(change to true if you selected blob for creating container)
  private_endpoint_location       = var.private_endpoint_location
  private_endpoint_name           = "az-pe-os1-nonprod-01"
  subnet_id                       = "/subscriptions/<subscription_id>/resourceGroups/<resourcegroup_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
  private_dns_zone_group_name     = data.azurerm_private_dns_zone.pe_dns.name
  private_dns_zone_ids            = [data.azurerm_private_dns_zone.pe_dns.id]
  subresource_names               = ["blob"] #blob,file,queue,table,dfs,sqlServer,web
  
  # To enable advanced threat protection set argument to `true`
  enable_advanced_threat_protection = false

  # Container lists with access_type to create
  containers_list = [
    { name = "mystore250", access_type = "blob" }
    #{ name = "blobstore251", access_type = "private" },
    #{ name = "containter252", access_type = "container" }
  ]

  # SMB file share with quota (GB) to create
  #file_shares = [
  #  { name = "smbfileshare1", quota = 50 } #,
  #  #  { name = "smbfileshare2", quota = 50 }
  #]
  
  # Storage tables
  #tables = ["table1", "table2", "table3"]
  
  # Storage queues
  #queues = ["queue1", "queue2"]
  
  #cors_rule = {
  #  allowed_origins = [
  #    "http://example.com",
  #    "https://example.com"
  #  ]
  #  allowed_methods    = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"]
  #  allowed_headers    = ["Authorization"]
  #  exposed_headers    = ["Cache-Control", "Content-Language"]
  #  max_age_in_seconds = 3600
  #}
  
  tags = var.tags
}
```
**variables.tf**
```hcl
variable "tags" {
  type        = map(any)
  description = "A map of the tags to use for the resources that are deployed."
  default = {
    "DataClassification" = "internal"
    "Owner"              = "hce"
    "Platform"           = "nonprod"
    "Environment"        = "nonprod"
  }
}

variable "azurerm_private_dns_zone" {
  type        = string
  description = "private dns name"
  default     = "privatelink.file.core.windows.net"
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "virtual network resource group name"
  default     = "az-rg-hce-test-01"
}

variable "shared_private_dns_zone_resource_group_name" {
  type        = string
  description = "Shared private dns zone resource group name"
  default     = "az-rg-dnsPrivateZone-test-01"
}

variable "private_endpoint_location" {
  type        = string
  description = "Shared private dns zone location"
  default     = "westeurope"
}
```
**outputs.tf**
```
output "storage_account_name" {
  description = "The name of the storage account."
  value       = module.storage_account.storage_account_name
}

output "storage_account_private_endpoint_name" {
  description = "The name of the storage account endpoint_name."
  value       = module.storage_account.storage_account_private_endpoint_name
}

output "storage_account_private_endpoint_subnet_id" {
  description = "The address of the endpoint_subnet_id."
  value       = module.storage_account.storage_account_private_endpoint_subnet_id
}

output "primary_access_key" {
  description = "The address of the primary_access_key."
  value       = module.storage_account.primary_access_key
}

output "containers" {
  description = "The name of the containers."
  value       = module.storage_account.containers
}

output "file_shares" {
  description = "The name of the file_shares."
  value       = module.storage_account.file_shares
}

output "tables" {
  description = "The name of the tables."
  value       = module.storage_account.tables
}

output "queues" {
  description = "The name of the queues."
  value       = module.storage_account.queues
}
```
**providers.tf**
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.44.1"
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
    features {}
    // Sub ID to be modified to fit environment
    subscription_id = "<subscription_id>"
    tenant_id       = "<tenant_ID>"
}

provider "azurerm" {
  features {}
  alias = "pe"
  subscription_id = "<subscription_ID>"
  tenant_id       = "<tenant_ID>"  
}
```

## Requirements

Name | Version
-----|--------
terraform | >= 1.1.9
azurerm | = 3.44.1

## Providers

| Name | Version |
|------|---------|
azurerm | = 3.44.1
