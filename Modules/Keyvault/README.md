# Service Principal Module

Terraform module to deploye a azure key vault and assign admin policy.

## Module Usage
```hcl
# main.tf configuration

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
  #admin_objects_ids               = var.admin_objects_ids
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

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`keyvault_name` | The name of the key vault | string | `""`
`resource_group_name` | Resource Group the resources will belong to | string | `""`
`location` | Location of the key vault | string | `""`
`tenant_id` | The Azure Active Directory tenant id that should be used for authenticating requests to the Key vault | string | `""`
`sku_name` | The Name of the SKU used for this key vault. | string | `""`
`enabled_for_deployment` | Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. | boolen | `true`
`enabled_for_disk_encryption` | Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | boolen | `true`
`enabled_for_template_deployment` | Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. | boolen | `true`
`purge_protection_enabled` | Whether to activate purge protection | boolen | `true`
`soft_delete_retention_days` | The number of days that items should be retained for once soft-deleted. | number | `90`
`rbac_authorization_enabled` | Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions instead of access policies. | boolen | `true`
`admin_objects_ids` | Ids of the objects that can do all operations on all keys, secrets and certificates | list | `""`
`network_acls`|The list of network acls|object|`""`
