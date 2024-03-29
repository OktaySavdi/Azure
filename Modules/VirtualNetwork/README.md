# Virtual Network Module

Terraform module used to create following resourses. This module will be used, when  user want to create only one route table for multiple subnet.
1. Virtual Network
2. Subnet
3. Single Route table
4. Metwork Security Group(NSG)
5. NSG and Subnet Association
6. Subnet and Route table Association


## Module Usage

```hcl
resource "azurerm_resource_group" "rg_name" {
  name     = var.resource_group_name
  location = var.location
}

# main.tf configuration
module "vnet" {
  source  = "git::https://myrepo.lan/modules.git//VirtualNetwork?ref=v3.97.1"
  providers = {
    azurerm = azurerm.subscription
  }

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  dns_servers         = var.dns_servers
  subnets             = var.subnets
  route_tables        = var.route_tables
  disk_access_name    = var.disk_access_name

  # Adding TAG's to your Azure resources (Required)
  tags       = var.default_tags
  depends_on = [azurerm_resource_group.rg_name]
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
  default     = "<subscription_ID>"
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "az-rg-it-dnsresolver-network-nonprod-01"
}

variable "location" {
  description = "The location/region to keep all your network resources."
  default     = "westeurope"
}

variable "vnet_name" {
  description = "Name of Azure Virtual Network"
  default     = "az-vnet-it-dnsresolver-network-nonprod-01"
}

ariable "nsg_name" {
  description = "Name of network security group"
  default     = "az-nsg-it-dnsresolver-network-nonprod-01"
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = ["10.10.10.0/21"]
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = ["10.10.10.1", "10.10.10.2"]
}

variable "disk_access_name" {
  description = "disk access name"
  default     = "az-da-it-dnsresolver-nonprod-01"
}

variable "route_tables" {
  description = "For each route table, create an object that contain fields"
  default = {
    az-rt_dnsresolver_nonprod_01 = {
      rt_name = "az-rt-dnsresolver-nonprod-01"
      routes = [
        { name = "default", address_prefix = "0.0.0.0/0", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.10.10.1" }
      ]
    },
    azu_rt_apg_dnsresolver_nonprod_01 = {
      rt_name = "az-rt-apg-dnsresolver-nonprod-01"
      routes = [
        { name = "default", address_prefix = "0.0.0.0/0", next_hop_type = "Internet" }
      ]
    }
  }
}

variable "nsgs" {
  description = "For each network security group, create an object that contain fields"
  default = {
    nsg_vnet = {
      name = "az-nsg-it-dnsresolver-network-nonprod-01"
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "dev"
      }
    },
    nsg_apg = {
      name = "az-nsg-apg-dnsresolver-nonprod-01"
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "dev"
      }
    }
  }
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default = {
  hce_vm_subne = {
      subnet_name            = "az-snet-it-dnsresolver-nonprod-01"
      subnet_address_prefix  = ["10.10.10.0/26"]
      service_endpoints      = ["Microsoft.Storage"]
      rt_name                = "az-rt-dnsresolver-nonprod-01"
      nsg_name               = "az-nsg-it-dnsresolver-network-nonprod-01"
      delegations            = []
      private_endpoint_network_policies_enabled = false
      private_endpoint_name  = "az-pe-it-dnsresolver-nonprod-01"
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "dev"
      }
    },
  hce_management_subnet = {
      subnet_name            = "az-snet-it-management-nonprod-01"
      subnet_address_prefix  = ["10.10.10.64/27"]
      service_endpoints      = ["Microsoft.Storage","Microsoft.Sql"]
      rt_name                = "az-rt-dnsresolver-nonprod-01"
      nsg_name               = "az-nsg-it-dnsresolver-network-nonprod-01"
      delegations            = []
      private_endpoint_network_policies_enabled = false
      private_endpoint_name  = "az-pe-it-management-nonprod-01"
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "dev"
      }
    },
  hce_dmz_subnet = {
      subnet_name            = "az-snet-it-dmz-nonprod-01"
      subnet_address_prefix  = ["10.10.10.96/28"]
      service_endpoints      = ["Microsoft.Storage"]
      rt_name                = "az-rt-apg-dnsresolver-nonprod-01"
      nsg_name               = "az-nsg-apg-dnsresolver-nonprod-01"
      delegations            = [ { delegationname = "Microsoft.Web.serverFarms", name = "Microsoft.Web/serverFarms", actions = ["Microsoft.Network/virtualNetworks/subnets/action"] }]
      private_endpoint_network_policies_enabled = false
      private_endpoint_name  = "az-pe-it-dmz-nonprod-01"
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
providers
```
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.97.1"
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
  subscription_id        = var.subscription 
  tenant_id              = "<tenant_ID>"
}

provider "azurerm" {
  features {}
  alias           = "subscription"
  subscription_id = var.subscription 
  tenant_id       = "<tenant_ID>"
}
```

## Requirements

Name | Version
-----|--------
terraform | >= 1.1.9
azurerm | = 3.97.1

## Providers

| Name | Version |
|------|---------|
azurerm | = 3.97.1

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`resource_group_name` | The name of the resource group | string | `""`
`location`|The location in which resources are created| string | `""`
`vnet_name`|The name of the virtual network| string | `""`
`vnet_address_space`|Virtual Network address space to be used |list|`[]`
`dns_servers` | List of DNS servers to use for virtual network | list |`[]`
`subnets`|For each subnet, create an object that contain fields|object|`{}`
`route_tables`|For each route, create an object that contain fields|object|`{}`
`default_tags`|A map of tags to add |map|`{}`
`disk_access_name`|The name of the disk access| string | `""`
`nsg_name`|The name of network security group| string | `""`

## Outputs

|Name | Description|
|---- | -----------|
`virtual_network_name` | The name of the virtual network.
`virtual_network_id` |The virtual NetworkConfiguration ID.
`network_security_group_ids`|List of Network security groups and ids
