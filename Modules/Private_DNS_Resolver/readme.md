# Azure Private Dns Resolver Module

Create Azure DNS Private Resolver with Inbound / Outbound endpoints as well as DNS Forwarding rule sets using Terraform.
To learn more about Azure DNS Private Resolver is check out Microsoft Learn: What is Azure DNS Private Resolver?
This Module can be used to create Azure DNS Private Resolver, one or two Inbound and Outbound Endpoints as well as one or two DNS Forwarding rule sets due to the limitations in supporting more then two Inbound/Outbound Endpoints and two DNS forwarding rule sets per Outbound Endpoint giving us total of four DNS Forwarding rule sets available, with two outbound endpoints.

## Module Usage

**main.tf**
```hcl
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name_for_vnet
}

module "dns_private_resolver" {
  source                              = "git::https://myrepo.domain.lan/modules.git//Private_DNS_Resolver"
  resource_group_name                 = var.resource_group_name_for_dnsresolver
  resource_group_name_for_dnsresolver = var.resource_group_name_for_dnsresolver
  location                            = var.location
  dns_resolver_name                   = var.dns_resolver_name
  virtual_network_id                  = data.azurerm_virtual_network.vnet.id
  forwarding_rules                    = var.forwarding_rules
  dns_resolver_inbound_endpoints      = var.dns_resolver_inbound_endpoints
  dns_resolver_outbound_endpoints     = var.dns_resolver_outbound_endpoints

  tags = var.tags
}
```
**variables.tf**
```hcl
variable "tags" {
  type = map(string)
  default = {
    "DataClassification" = "internal"
    "Owner"              = "hce"
    "Platform"           = "hce"
    "Environment"        = "nonprod"
  }
}

variable "forwarding_rules" {
  default = []
}

variable "resource_group_name_for_vnet" {
  description = "A container that holds related resources for an Azure solution"
  default     = "az-rg-hce-test-01"
}

variable "resource_group_name_for_dnsresolver" {
  description = "A container that holds related resources for an Azure solution"
  default     = "az-rg-hce-test-01"
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "westeurope"
}

variable "vnet_name" {
  description = "Name of Azure Virtual Network"
  default     = "az-vnet-dnsresolver-hce-test-01"
}

variable "dns_resolver_name" {
  description = "Specifies the name which should be used for this Private DNS Resolver"
  default     = "az-pdr-westeu-prod-01"
}

variable "dns_resolver_inbound_endpoints" {
  description = "For each subnet, create an object that contain fields"
  # There is currently only support for two Inbound endpoints per Private Resolver.
  default = [
    {
      inbound_endpoint_name = "inbound-westeu"
      inbound_subnet_id     = "/subscriptions/<sub_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/az-snet-dnsresolver-inbound-test-01"
    }
  ]
}

variable "dns_resolver_outbound_endpoints" {
  description = "For each subnet, create an object that contain fields"
  # There is currently only support for two Inbound endpoints per Private Resolver.
  default = [
    {
      outbound_endpoint_name = "outbound-westeu"
      outbound_subnet_id     = "/subscriptions/<sub_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/az-snet-dnsresolver-outbound-test-01"
      forwarding_rulesets = [
        # There is currently only support for two DNS forwarding rulesets per outbound endpoint.
        {
          forwarding_ruleset_name = "ruleset-westeu1"
        },
        {
          forwarding_ruleset_name = "ruleset-westeu2"
        },
      ]
    }
  ]
}
```
**terraform.tfvars**
```hcl
forwarding_rules = [
  {
    name                   = "mydomain.lan"
    domain_name            = "mydomain.lan."
    enabled                = true
    forwarding_ruleset_name = "ruleset-westeu1"

    target_dns_servers = [
      {
        ip_address = "10.10.10.10"
        port       = 53
      },
      {
        ip_address = "10.10.10.11"
        port       = 53
      }
    ]
  }, 
  {
    name                   = "corp.mycompany2.com"
    domain_name            = "corp.mycompany2.com."
    enabled                = true
    forwarding_ruleset_name = "ruleset-westeu2"

    target_dns_servers = [
      {
        ip_address = "10.10.10.10"
        port       = 53
      },
      {
        ip_address = "10.10.10.11"
        port       = 53
      }
    ]
  }
]
```
**providers.tf**
```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.79.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "<subcription_id>
  tenant_id       = "<tenant_id>
  features {}
}
```
## Description
Create Azure DNS Private Resolver with Inbound / Outbound endpoints as well as DNS Forwarding rule sets using Terraform.

To learn more about Azure DNS Private Reslover is check out Microsoft Learn: [What is Azure DNS Private Resolver?](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)

This Module can be used to create Azure DNS Private Resolver, one or two Inbound and Outbound Endpoints as well as one or two DNS Forwarding rule sets due to the limitations in supporting more then two Inbound/Outbound Endpoints and two DNS forwarding rule sets per Outbound Endpoint giving us total of four DNS Forwarding rule sets available, with two outbound endpoints.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.36.0 |

## Resources

- [azurerm_private_dns_resolver.private_dns_resolver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) 
- [azurerm_private_dns_resolver_dns_forwarding_ruleset.forwarding_ruleset](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_dns_forwarding_ruleset)
- [azurerm_private_dns_resolver_inbound_endpoint.private_dns_resolver_inbound_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint)
- [azurerm_private_dns_resolver_outbound_endpoint.private_dns_resolver_outbound_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint)

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required): Name of the resource group where resources should be deployed. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required): Region / Location where Azure DNS Resolver should be deployed | `string` | n/a | yes |
| <a name="input_dns_resolver_name"></a> [dns\_resolver\_name](#input\_dns\_resolver\_name) | (Required): Name of the Azure DNS Private Resolver | `string` | n/a | yes |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | (Required): ID of the associated virtual network | `string` | n/a | yes |
| <a name="input_dns_resolver_inbound_endpoints"></a> [dns\_resolver\_inbound\_endpoints](#input\_dns\_resolver\_inbound\_endpoints) | (Optional): Set of Azure Private DNS resolver Inbound Endpoints | <pre>set(object({<br>    inbound_endpoint_name = string<br>    inbound_subnet_id     = string<br>  }))</pre> | `[]` | no |
| <a name="input_dns_resolver_outbound_endpoints"></a> [dns\_resolver\_outbound\_endpoints](#input\_dns\_resolver\_outbound\_endpoints) | (Optional): Set of Azure Private DNS resolver Outbound Endpoints with one or more Forwarding Rule sets | <pre>set(object({<br>    outbound_endpoint_name = string<br>    outbound_subnet_id     = string<br>    forwarding_rulesets = optional(set(object({<br>      forwarding_ruleset_name = optional(string)<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional): Resource Tags | `map(string)` | `{}` | no |

## Other Resouces
- [What is Azure DNS Private Resolver ?](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)
- [Terraform AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [haflidif](https://github.com/haflidif/terraform-azurerm-dns-private-resolver)
