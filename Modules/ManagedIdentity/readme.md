## Module Usage

```tf

data "azurerm_private_dns_zone" "full_zone" {
  provider = azurerm.private-dns
  name     = var.private_dns_zone_id
}

module "managedIdentity" {
  source              = "git::https://<git_address>/hce-public/modules.git//ManagedIdentity"
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  assignments = [
    {
      scope              = "/subscriptions/<subscription_ID>/resourceGroups/<resourcegroup_name>"
      role_definition_name = "Custom - Contributor with limited Network role"
    },
    {
      scope              = "/subscriptions/<subscription_ID>/resourceGroups/<resourcegroup_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
      role_definition_name = "Custom - Virtual network user"
    },
    {
      scope              = data.azurerm_private_dns_zone.full_zone.id
      role_definition_name = "Custom - Private DNS Zone Contributor"
    }
  ]
}
```
***variables**
```tf
variable "tags" {
  type = map(string)
  default = {
    "DataClassification" = "internal"
    "Owner"              = "<team_Name>"
    "Platform"           = "<platform_name>"
    "Environment"        = "nonprod"
  }
}

variable "name" {
  description = "Specifies the name of this User Assigned Identity. Changing this forces a new User Assigned Identity to be created"
  type        = string
  default     = "az-mi-hce-test-10"
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created"
  type        = string
  default     = "germanywestcentral"
}

variable "resource_group_name" {
  description = "Specifies the name of the Resource Group within which this User Assigned Identity should exist. Changing this forces a new User Assigned Identity to be created."
  type        = string
  default     = "<resourcegroup_name>"
}

variable "subscription" {
  description = "Subscription info"
  type        = string
  default     = "<subscription_ID>"
}

variable "private_dns_zone_id" {
  description = "private dns zone name"
  type        = string
  default     = "privatelink.germanywestcentral.azmk8s.io"
}

variable "private_dns_zone_subscription" {
  description = "private dns zone subscription"
  type        = string
  default     = "<subscription_ID>"
}
```
***providers***
```tf
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
  subscription_id        = var.subscription
  tenant_id              = "<tenant_ID>"
  features {}
}

provider "azurerm" {
  alias                  = "private-dns"
  subscription_id        = "<subscription_ID>"
  tenant_id              = "<tenant_ID>"
  features {}
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
azuread | = 2.34.1
