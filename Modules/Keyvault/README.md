# Keyvault Module

Terraform module to deploye a azure key vault and assign admin policy.

## Module Usage

**terraform.tfvars**
```hcl
# a existing RG name to use an existing resource group. Location will be same as existing RG. 
resource_group_name        = "az-rg-hce-app-prod-01"
key_vault_name             = "az-kv-hce-prod-01"
key_vault_sku_pricing_tier = "standard"
location                   = "germanywestcentral"

# Creating Private Endpoint requires
virtual_network_name        = "az-vnet-hce-kv-prod-01" 
subnet_name                 = "az-snet-hce-kv-prod-01"
network_resource_group      = "az-rg-hce-kv-prod-01"

# Once `Purge Protection` has been Enabled it's not possible to Disable it
# The default retention period is 90 days, possible values are from 7 to 90 days
# use `soft_delete_retention_days` to set the retention period
enable_purge_protection = false
# soft_delete_retention_days = 90

# Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions.
enable_rbac_authorization       = true

# Access policies for users, you can provide list of Azure AD users and set permissions.
#access_policies = [
#    {
#      azure_ad_user_principal_names = ["a-osavd@greentube.com", "a-asind@greentube.com"]
#      key_permissions               = ["Get", "List"]
#      secret_permissions            = ["Get", "List"]
#      certificate_permissions       = ["Get", "Import", "List"]
#      storage_permissions           = ["Backup", "Get", "List", "Recover"]
#    },
#
#    # Access policies for AD Groups
#    # to enable this feature, provide a list of Azure AD groups and set permissions as required.
#    {
#      azure_ad_group_names    = ["TEAM_HybridCloudEngineering_Admins", "TEAM_ITOperations_Admins"]
#      key_permissions         = ["Get", "List"]
#      secret_permissions      = ["Get", "List"]
#      certificate_permissions = ["Get", "Import", "List"]
#      storage_permissions     = ["Backup", "Get", "List", "Recover"]
#    },
#
#    # Access policies for Azure AD Service Principlas
#    # To enable this feature, provide a list of Azure AD SPN and set permissions as required.
#    {
#      azure_ad_service_principal_names = ["az-sp-asm-aqrate-exchangeonline-prod-01", "az-sp-architecture-skills-base-prod-01"]
#      key_permissions                  = ["Get", "List"]
#      secret_permissions               = ["Get", "List"]
#      certificate_permissions          = ["Get", "Import", "List"]
#      storage_permissions              = ["Backup", "Get", "List", "Recover"]
#    }
#]

network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"

    # One or more IP Addresses, or CIDR Blocks to access this Key Vault.
    ip_rules                   = ["185.16.77.248"]

    # One or more Subnet ID's to access this Key Vault.
    virtual_network_subnet_ids = ["/subscriptions/<sub_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"]
}

# Adding TAG's to your Azure resources 
tags = {
  Env          = "Prod"
  Owner        = "user@example.com"
  BusinessUnit = "CORP"
  ServiceClass = "Gold"
}
```
**main.tf**
```hcl
module "key-vault" {
  source = "git::https://my_git.lan/modules.git//Keyvault?ref=v3.97.1"
  
  key_vault_name                  = var.key_vault_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  key_vault_sku_pricing_tier      = var.key_vault_sku_pricing_tier
  network_acls                    = var.network_acls
  access_policies                 = var.access_policies
  virtual_network_name            = var.virtual_network_name
  subnet_name                     = var.subnet_name
  network_resource_group          = var.network_resource_group
  soft_delete_retention_days      = var.soft_delete_retention_days
  enable_rbac_authorization       = var.enable_rbac_authorization

  tags = var.tags
}
```
**variables**
```hcl
variable "access_policies" {
  description = "For each access_policies, create an object that contain fields"
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Resource Group the resources will belong to"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure location for Key Vault."
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "key vaultname"
  type        = string
  default     = null
}

variable "key_vault_sku_pricing_tier" {
  type        = string
  description = "Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium"
  default     = null
}

variable "enable_purge_protection" {
  type        = bool
  description = "(Optional) Is Purge Protection enabled for this Key Vault?"
  default     = false
}

variable "soft_delete_retention_days" {
  type        = string
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  default     = null
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "subnet_name" {
  type        = string
  description = "subnet name"
  default     = null
}

variable "virtual_network_name" {
  type        = string
  description = "virtual network name"
  default     = null
}

variable "network_resource_group" {
  type        = string
  description = "virtual network name"
  default     = null
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions"
  default     = false
}
```
**Providers**
```hcl
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
  subscription_id = "xxxxxxx-xxxxxxx-xxxxxxx-xxxxxxx"
  tenant_id       = "xxxxxxx-xxxxxxx-xxxxxxx-xxxxxxx"
  features {}
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.97.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | For each access\_policies, create an object that contain fields | `map` | `{}` | no |
| <a name="input_enable_purge_protection"></a> [enable\_purge\_protection](#input\_enable\_purge\_protection) | (Optional) Is Purge Protection enabled for this Key Vault? | `bool` | `false` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | Specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions | `bool` | `false` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | key vaultname | `string` | `null` | no |
| <a name="input_key_vault_sku_pricing_tier"></a> [key\_vault\_sku\_pricing\_tier](#input\_key\_vault\_sku\_pricing\_tier) | Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location for Key Vault. | `string` | `null` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network rules to apply to key vault. | <pre>object({<br>    bypass                     = string<br>    default_action             = string<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = list(string)<br>  })</pre> | `null` | no |
| <a name="input_network_resource_group"></a> [network\_resource\_group](#input\_network\_resource\_group) | virtual network name | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group the resources will belong to | `string` | `null` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | (Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days. | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | subnet name | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | virtual network name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | Name of key vault created. |
| <a name="output_key_vault_private_endpoint"></a> [key\_vault\_private\_endpoint](#output\_key\_vault\_private\_endpoint) | The ID of the Key Vault Private Endpoint |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault, used for performing operations on keys and secrets. |
