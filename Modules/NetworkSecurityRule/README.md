# Network Security Rule Module

Terraform module for assigning security rules to different network security group.

## Module Usage

```hcl
# main.tf configuration
# main.tf configuration
provider "azurerm" {
  features {}
}

module "security-rule" {
  source = "git::https://<git_address>/hce-public/modules.git//NetworkSecurityRule"

  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name

  # Adding security rules
  #security_rules = var.security_rules

  security_rules = [
    {
      name                        = "in-allow-office-all"
      description                 = "OFFICE private networks incoming"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "10.10.0.0/15"
      destination_address_prefix  = var.destination_address_prefix
      access                      = "Allow"
      priority                    = 110
      direction                   = "Inbound"
      resource_group_name         = var.resource_group_name
      network_security_group_name = var.network_security_group_name
    },
    {
      name                        = "in-allow-gtstg-net"
      description                 = "STG net incoming"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "10.10.0.0/16"
      destination_address_prefix  = var.destination_address_prefix
      access                      = "Allow"
      priority                    = 111
      direction                   = "Inbound"
      resource_group_name         = var.resource_group_name
      network_security_group_name = var.network_security_group_name
    }
  ]
}

```

```hc
# variables.tf configuration

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure"
  type        = string
  default     = "az-rg-hce-test-01"
}

variable "network_security_group_name" {
  description = "Network security group name"
  type        = string
  default     = "az-nsg-snet-hce-test-01"
}

variable "destination_address_prefix" {
  description = "destination address prefix"
  type        = string
  default     = "10.10.10.0/24"
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
`network_security_group_name` | The name of the network security group | string | `""`
`security_rules`|The list of role assignments to this principal|list|`[]`
