# Virtual Network Module

Terraform module used to create following resourses. This module will be used, when  user want to create related route table for each subnet.
1. Virtual Network
2. Subnet
3. Route table
4. Metwork Security Group(NSG)
5. NSG and Subnet Association
6. Subnet and Route table Association

## Module Usage

```hcl
# main.tf configuration

# Azurerm provider configuration
module "vnet" {
  source  = "git::https://<git_address>/hce-public/modules.git//VirtualNetwork01"
  providers = {
    azurerm = azurerm.subscription
  }

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  dns_servers         = var.dns_servers
  subnets             = var.subnets
  
  # Adding TAG's to your Azure resources (Required)
  tags       = var.default_tags
}
```

```hcl

# variables.tf configuration
variable "default_tags" {
  type = map(any)
  default = {
    DataClassification = "internal"
    Owner              = "hce"
    Platform           = "hce"
    Environment        = "dev"
  }
}

variable "subscription" {
  description = "Azure Subscription"
  default     = "<subscription_id>"
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "az-rg-hce-test-01"
}

variable "location" {
  description = "The location/region to keep all your network resources."
  default     = "westeurope"
}

variable "vnet_name" {
  description = "Name of Azure Virtual Network"
  default     = "az-vnet-hce-test-01"
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = ["10.10.10.0/20"]
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = ["10.10.10.1", "10.10.10.2"]
}

variable "rt_name" {
  description = "Name of Route Table"
  default     = "az-rt-snet-hce-test-01"
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default = {
  devops_subnet = {
      subnet_name            = "az-snet-hce-devops-dev-01"
      subnet_address_prefix  = ["10.10.10.0/24"]
      nsg_name               = "az-nsg-snet-hce-devops-dev-01"
      service_endpoints      = ["Microsoft.Storage"]
      rt_name                = "az-rt-snet-hce-devops-dev-01"
      private_endpoint_network_policies_enabled = false
      routes = [
        { name = "default", address_prefix = "0.0.0.0/0", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "<my_azure_firewall_ip_addr>" }
      ]
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "dev"
      }
    },

  central_monitoring_subnet = {
      subnet_name            = "az-snet-hce-monitoring-dev-01"
      subnet_address_prefix  = ["10.10.11.0/24"]
      nsg_name               = "az-nsg-snet-hce-central-dev-01"
      service_endpoints      = ["Microsoft.Storage"]
      rt_name                = "az-rt-snet-hce-monitoring-dev-01"
      private_endpoint_network_policies_enabled = false
      routes = [
        { name = "default", address_prefix = "0.0.0.0/0", next_hop_type = "Internet" }
      ]
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "dev"
      }
    }
  }
}

```
```hcl

# providers.tf configuration

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
}

provider "azurerm" {
  alias                  = "subscription"
  subscription_id        = "<subscription_id>"
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

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`resource_group_name` | The name of the resource group | string | `""`
`location`|The location in which resources are created| string | `""`
`vnet_name`|The name of the virtual network| string | `""`
`vnet_address_space`|Virtual Network address space to be used |list|`[]`
`dns_servers` | List of DNS servers to use for virtual network | list |`[]`
`subnets`|For each subnet, create an object that contain fields|object|`{}`
`default_tags`|A map of tags to add |map|`{}`

## Outputs

|Name | Description|
|---- | -----------|
`virtual_network_name` | The name of the virtual network.
`virtual_network_id` |The virtual NetworkConfiguration ID.
`network_security_group_ids`|List of Network security groups and ids