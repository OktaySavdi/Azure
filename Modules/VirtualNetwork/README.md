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
# main.tf configuration
module "vnet" {
  source  = "git::https://<git_address>/hce-public/modules.git//VirtualNetwork"
  providers = {
    azurerm = azurerm.subscription
  }

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  dns_servers         = var.dns_servers
  subnets             = var.subnets
  rt_name             = var.rt_name
  
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
    Environment        = "nonprod"
  }
}

variable "subscription" {
  description = "Azure Subscription"
  default     = "<subscription_ID>"
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "az-rg-hce-network-nonprod-01"
}

variable "location" {
  description = "The location/region to keep all your network resources."
  default     = "westeurope"
}

variable "vnet_name" {
  description = "Name of Azure Virtual Network"
  default     = "az-vnet-hce-network-nonprod-01"
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = ["10.10.10.0/21"]
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = ["10.10.10.1", "10.10.10.2"]
}

variable "rt_name" {
  description = "Name of Route Table"
  default     = "az-rt-snet-hce-nonprod-01"
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default = {
  hce_vm_subnet = {
      subnet_name            = "az-snet-hce-vm-nonprod-01"
      subnet_address_prefix  = ["10.10.10.0/26"]
      nsg_name               = "az-nsg-snet-hce-vm-nonprod-01"
      service_endpoints      = ["Microsoft.Storage"]
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "nonprod"
      }
    },
  hce_management_subnet = {
      subnet_name            = "az-snet-hce-management-nonprod-01"
      subnet_address_prefix  = ["10.10.10.64/27"]
      nsg_name               = "az-nsg-snet-hce-nonprod-01"
      service_endpoints      = ["Microsoft.Storage","Microsoft.Sql"]
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "nonprod"
      }
    },
  hce_dmz_subnet = {
      subnet_name            = "az-snet-hce-dmz-nonprod-01"
      subnet_address_prefix  = ["10.10.10.96/28"]
      nsg_name               = "az-nsg-snet-hce-dmz-nonprod-01"
      service_endpoints      = ["Microsoft.Storage"]
      tags = {
        DataClassification = "internal"
        Owner              = "hce"
        Platform           = "hce"
        Environment        = "nonprod"
      }
    }
  }
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
`rt_name`|Name of Route Table| object |`{}`
`default_tags`|A map of tags to add |map|`{}`

## Outputs

|Name | Description|
|---- | -----------|
`virtual_network_name` | The name of the virtual network.
`virtual_network_id` |The virtual NetworkConfiguration ID.
`network_security_group_ids`|List of Network security groups and ids
