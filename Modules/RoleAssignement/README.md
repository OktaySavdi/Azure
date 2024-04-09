# Role Assignement Module

Terraform module for assigning role to different type of principals.

## Module Usage

```hcl
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "role-assignement" {
  source  = "git::https://<git_address>/hce-public/modules.git//RoleAssignement?ref=v3.97.1""

  # Adding roles and scope to service principal
  assignments = [
    {
      scope                = "/subscriptions/<subscription_ID>/resourceGroups/<resourcegroup_name>"
      role_definition_name = "Contributor"
      principal_id         = "111-1111-11-111-1111"
    },
    {
      scope                = "/subscriptions/<subscription_ID>"
      role_definition_name = "Private DNS Zone Contributor"
      principal_id         = "111-1111-11-111-1111"
    }
  ]
}
```
```hcl
# providers.tf configuration
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.97.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "<rg_name>"
    storage_account_name = "<sa_name>"
    container_name       = "<container_name>"
    key                  = "/subscription/<sub_name>/prod/IAM/terraform.tfstate"
  }

}

provider "azurerm" {
  subscription_id        = "xxx-xxx-xxx-xxx-xxx"
  tenant_id              = "xxx-xxx-xxx-xxx-xxx"
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
`assignments`|The list of role assignments to this principal|list|`[]`
