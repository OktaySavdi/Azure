# Storage Account Module

Terraform module for Storage Account

## Module Usage

```hcl
variable "azurerm_private_dns_zone" {
  type        = string
  description = "private dns name"
  default     = "privatelink.file.core.windows.net"
}

variable "shared_private_dns_zone_resource_group_name" {
  type        = string
  description = "Shared private dns zone resource group name"
  default     = "<privatedns_resourcegroup_name>"
}

data "azurerm_private_dns_zone" "pe_dns" {
  provider            = azurerm.pe
  name                = var.azurerm_private_dns_zone
  resource_group_name = var.shared_private_dns_zone_resource_group_name
}

module "storage" {
  source                          = "git::https://<git_address>/hce-public/modules.git//StorageAccount"
  resource_group_name             = "az-rg-hce-test-01"
  storage_account_name            = "mystorageaccountname01"
  location                        = "germanywestcentral"
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  private_endpoint_name           = "az-pe-hce-nonprod-01"
  subnet_id                       = "/subscriptions/<subscription_id>/resourceGroups/<resourcegroup_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
  private_dns_zone_group_name     = data.azurerm_private_dns_zone.pe_dns.name
  private_dns_zone_ids            = [data.azurerm_private_dns_zone.pe_dns.id]
  subresource_names               = ["file"] #blob,file,queue,table,dfs,sqlServer,web
  
  # To enable advanced threat protection set argument to `true`
  enable_advanced_threat_protection = false

  # Container lists with access_type to create
  #containers_list = [
    #{ name = "mystore250", access_type = "blob" },
    #{ name = "blobstore251", access_type = "private" },
    #{ name = "containter252", access_type = "container" }
  #]

  # SMB file share with quota (GB) to create
  file_shares = [
    { name = "smbfileshare1", quota = 50 }#,
  #  { name = "smbfileshare2", quota = 50 }
  ]
  
  # Storage tables
  #tables = ["table1", "table2", "table3"]
  
  # Storage queues
  #queues = ["queue1", "queue2"]
  
  tags = {
    "DataClassification" = "internal"
    "Owner"              = "<team_name>"
    "Platform"           = "<platform_name>"
    "Environment"        = "nonprod"
  }
}
```
provider.tf
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.38.0"
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