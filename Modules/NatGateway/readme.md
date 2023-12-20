# NAT Gateway Module

Terraform module used to create following resourses. This module will be used, when  user want to create a NAT gateway to access the public internet, more details can be found here : https://learn.microsoft.com/en-us/azure/nat-gateway/nat-overview.

This Module creating the below resources:

1. Public IP
2. NAT Gateway
3. Public IP and NAT Gateway Association
4. Subnet(s) and NAT Gateway Association

Note: Please make sure to update the provider file with the proper vaules (subscription, tfstate, ...)

## Module Usage

```hcl

# main.tf configuration
module "vnet" {
  source  = "git::https://ato-hce-git1.gtoffice.lan/hce-public/modules.git//NatGateway?ref=v3.44.1"
  providers = {
    azurerm = azurerm.subscription
  }

  resource_group_name = var.resource_group_name
  location            = var.location
  public_ip_name      = var.public_ip_name
  allocation_method   = var.allocation_method
  public_ip_sku       = var.public_ip_sku
  nat_gateway_name    = var.nat_gateway_name
  subnets             = var.subnets
    
  # Adding TAG's to your Azure resources (Required)
  tags                = var.default_tags
}
```

```hcl

# variables.tf configuration
variable "default_tags" {
  type = map(any)
  default = {
    DataClassification = "internal"
    Owner              = "it-hce"
    Platform           = "HCE"
    Environment        = "dev"
  }
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "az-rg-hce-test-01"
}

variable "location" {
  description = "The location/region to keep all your network resources."
  default     = "westeurope"
}

variable "public_ip_name" {
  description = "Name of the public ip for outbound nat gateway"
  default     = "az-pip-hce-test-01"
}

variable "allocation_method" {
  description = "Define the allocation method. It can be 'Static' or 'Dynamic'"
  default     = "Static"
}

variable "public_ip_sku" {
  description = "Skus for public ip can be 'Basic' or 'Standard'."
  default     = "Standard"
}

variable "nat_gateway_name" {
  description = "Define nat gateway name."
  default     = "az-natg-hce-test-01"
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default     = ["/subscriptions/<subscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name1>","/subscriptions/<subscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name2>"]
}

```
providers
```
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
    subscription_id = var.subscription 
    tenant_id       = "xxxxx-xxxxxxxxx-xxxxxxxxxx-xxxxxxx"
}

provider "azurerm" {
  features {}
  alias           = "subscription"
  subscription_id = var.subscription 
  tenant_id       = "xxxxx-xxxxxxxxx-xxxxxxxxxx-xxxxxxx"
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

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`resource_group_name` | The name of the resource group | string | `""`
`location`|The location in which resources are created| string | `""`
`public_ip_name`|the name of the public IP attached to NatGateway |string|`""`
`public_ip_sku` | SKU of the public IP | string |`""`
`allocation_method`|Allocation method to locate the Public IP| string | `""`
`subnets`|List of the subnet(s) has to be attached to the NatGateway |Lsit|`[]`
`nat_gateway_name`| The Name of the NAT Gateway|string|`""`
`default_tags`|A map of tags to add |map|`{}`
