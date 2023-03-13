# Harbor Project RoleAssignement Module

Terraform module for creating harbor projects.

## Module Usage

```hcl
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "harbor-project" {
  source                = "git::https://<git_address>/hce-public/modules.git//HarborProject_RoleAssignement"
  key_vault_secret_name = var.key_vault_secret_name

  define_group = {
    group1 = {
      group_name    = var.define_group.group_name
      role          = var.define_group.role
      ldap_group_dn = var.define_group.ldap_group_dn
    }
  }

  key_vault_name           = "azgwc-kv-gtit-hce-prod"
  resource_group_name      = "azgwc-rg-gtit-hce-prod-01"
  harbor_project_url       = var.harbor_project_url
  harbor_project_name      = var.harbor_project_name
}
```
variables
```hcl
variable "harbor_project_name" {
  description = "harbor project name"
  type        = string
  default     = "hce"
}

variable "key_vault_secret_name" {
  description = "key_vault_secret_name. Possible values are harbor-stg and harbor-prod"
  type        = string
  default     = "harbor-prod"
}

variable "harbor_project_url" {
  description = "harbor_project_url. Possible values are https://prod-harbor1.domain.com and "https://stg-harbor1.domain.com""
  type        = string
  default     = "https://prod-harbor1.domain.com"
}

variable "define_group" {
  type = map(string)
  default = {
    "group_name"    = "<my group name>"                                                         # (Required) The of the project that will be created in harbor (must be lowercase).
    "role"          = "projectadmin"                                                            # (Required) The premissions that the entity will be granted.
    "ldap_group_dn" = "CN=<my_CN>,OU=RoleGroups,OU=<my_OU>,DC=<my_DC>,DC=<my_DC>"               # The distinguished name of the group within AD/LDAP
  }
}
```
providers
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.47.0"
    }
  }

 #  backend "azurerm" {
 #    resource_group_name  = "<your rg>" #change
 #    storage_account_name = "<your sa>" #change
 #    container_name       = "<your cn>" #change
 #    key                  = "/<your directoy>" #change
 #  }
}

provider "azurerm" {
    features {}
    // Sub ID to be modified to fit environment
    subscription_id = "<subscription_ID>"
    tenant_id       = "<tenant_ID>"
}
```

## Requirements

Name | Version
-----|--------
terraform | >= 0.13
azurerm | >= 3.0.0

## Providers

| Name | Version |
|------|---------|
azurerm | = 3.0.0
harbor | = 3.7.1

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`harbor-projects-roleassignement`|The list of harbor projects`[]`
