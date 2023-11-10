# Azure Private Endpoint Module

## Module Usage

```hcl
data "azurerm_client_config" "current" {}

data "azurerm_private_dns_zone" "vault_dns" {
  provider            = azurerm.pe
  name                = var.azurerm_private_dns_zone
  resource_group_name = var.shared_private_dns_zone_resource_group_name
}

data "azurerm_subnet" "sn" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group_name
}

module "keyvault_creation" {
  source = "git::https://<git_address>/hce-public/modules.git//Keyvault"
  
  keyvault_name                   = var.keyvault_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.sku_name
  #admin_objects_ids              = var.admin_objects_ids
  network_acls                    = var.network_acls
  rbac_authorization_enabled      = var.rbac_authorization_enabled

  tags = var.tags
}

module "private-endpoint_example_simple" {
  source =  "git::https://<git_address>/hce-public/modules.git//PrivateEndpoint"
  
  pe_resource_group_name = var.resource_group_name
  private_endpoint_name  = var.private_endpoint_name
  location               = var.location
  subresource_names      = ["Vault"]
  pe_subnet_id           = data.azurerm_subnet.sn.id
  endpoint_resource_id   = module.keyvault_creation.key_vault_id

  dns = {
    zone_ids  = [data.azurerm_private_dns_zone.vault_dns.id]
    zone_name = data.azurerm_private_dns_zone.vault_dns.name
  }

  depends_on = [module.keyvault_creation]
}

resource "azurerm_role_assignment" "rbac_keyvault_role_assign" {
  count                = length(var.assign_role)
  scope                = module.keyvault_creation.key_vault_id
  role_definition_name = var.assign_role[count.index].role
  principal_id         = var.assign_role[count.index].principal_id
}
```
variables
```hcl
variable "tags" {
  type        = map(any)
  description = "A map of the tags to use for the resources that are deployed."
  default = {
    "DataClassification" = "internal"
    "Owner"              = "hce"
    "Platform"           = "hce"
    "Environment"        = "prod"
  }
}

variable "keyvault_name" {
  description = "key vaultname"
  type        = string
  default     = "az-kv-hce-test-01"
}

variable "private_endpoint_name" {
  type        = string
  description = "private endpoint name"
  default     = "az-pe-hce-test"
}

variable "resource_group_name" {
  description = "Resource Group the resources will belong to"
  type        = string
  default     = "az-rg-hce-test-01"
}

variable "location" {
  description = "Azure location for Key Vault."
  type        = string
  default     = "westeurope"
}

variable "azurerm_private_dns_zone" {
  type        = string
  description = "private dns name"
  default     = "privatelink.vaultcore.azure.net"
}

variable "subnet_name" {
  type        = string
  description = "subnet name"
  default     = "public-subnet"
}

variable "virtual_network_name" {
  type        = string
  description = "virtual network name"
  default     = "az-vnet-hce-test-01"
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "virtual network resource group name"
  default     = "az-rg-hce-test-01"
}

variable "shared_private_dns_zone_resource_group_name" {
  type        = string
  description = "Shared private dns zone resource group name"
  default     = "<privatedns_resourcegroup_name>"
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are \"standard\" and \"premium\"."
  type        = string
  default     = "standard"
}

variable "rbac_authorization_enabled" {
  type        = bool
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions instead of access policies."
  default     = true
}

variable "network_acls" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. Set to `null` to disable. See https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass for more information."
  type = object({
    bypass                     = optional(string, "None"),
    default_action             = optional(string, "Deny"),
    ip_rules                   = optional(list(string)),
    virtual_network_subnet_ids = optional(list(string)),
  })
  default = {
    bypass         = "AzureServices"
    default_action = "Deny"
    //ipRules               = []
    //virtualNetworkRules   = []
  }
}

variable "assign_role" {
  type = list(object({
    principal_id         = string
    role                 = string
  }))
  default = [
    {
     principal_id = "<Group_ID>"
     role = "Key Vault Administrator"
    },
    {
     principal_id = "<Group_ID>"
     role = "Reader"
    }
  ]
}
```
Providers
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
    subscription_id = "<subscription_ID>"
    tenant_id       = "<tenant_ID>"
}

provider "azurerm" {
  features {}
  alias = "pe"
  subscription_id = "<subscription_ID>"
  tenant_id       = "<tenant_ID>"  
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns"></a> [dns](#input\_dns) | The Details of the private DNS Zone where the Private Endpoint will register. | <pre>object({<br>    zone_ids  = list(string)<br>    zone_name = string<br>  })</pre> | n/a | yes |
| <a name="input_endpoint_resource_id"></a> [endpoint\_resource\_id](#input\_endpoint\_resource\_id) | The ID of the resource that the new Private Endpoint will be assigned to. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the private Endpoint will be created | `string` | `"uksouth"` | no |
| <a name="input_pe_resource_group_name"></a> [pe\_resource\_group\_name](#input\_pe\_resource\_group\_name) | The name of the Resource group where the the Private Endpoint will be created. | `string` | n/a | yes |
| <a name="input_pe_subnet_id"></a> [pe\_subnet\_id](#input\_pe\_subnet\_id) | The ID of the Subnet where the Private Endpoint IP address will be created. | `string` | n/a | yes |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | The name to assign to the new private Endpoint. | `string` | n/a | yes |
| <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names) | list of subresource names which the Private Endpoint is able to connect to (eg, `blob` or `blob_secondary`), https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pe_name"></a> [pe\_name](#output\_pe\_name) | n/a |
<!-- END_TF_DOCS -->
