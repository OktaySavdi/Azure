# PublicIP Module

Terraform module for assigning role to different type of principals.

## Module Usage

**main.tf**
```hcl
module "az_public_ip" {
  source              = "git::https://myrepo.com/modules.git//PublicIP?ref=v3.97.1"
  public_ip = [
    {
      name                = "az-pi-hce-harbor-prod-01"
      resource_group_name = "az-rg-hce-harbor-prod-01"
      location            = "westeurope"
      allocation_method   = "Static"
      domain_name_label   = null
      sku                 = "Standard"
      tags = {
        "DataClassification" = "Internal"
        "Owner"              = "HCE"
        "Platform"           = "IT"
        "Environment"        = "Nonprod"
      }
    },
    {
      name                = "az-pi-hce-harbor-prod-02"
      resource_group_name = "az-rg-hce-harbor-prod-01"
      location            = "westeurope"
      allocation_method   = "Dynamic"
      domain_name_label   = null
      sku                 = "Basic"
      tags = {
        "DataClassification" = "Internal"
        "Owner"              = "HCE"
        "Platform"           = "IT"
        "Environment"        = "Nonprod"
      }
    }
  ]
}
```
**outputs.tf**
```hcl
output "public_ips" {
  value = [
    for ip in module.az_public_ip.public_ips :
    {
      name                = ip.name
      id                  = ip.id
      ip_address          = ip.ip_address
      resource_group_name = ip.resource_group_name
    }
  ]
}
```
**providers.tf**
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
    features {}
    // Sub ID to be modified to fit the environment
    subscription_id = "xxx-xxx-xxx-xxx-xxx-xxx"
    tenant_id       = "xxx-xxx-xxx-xxx-xxx-xxx"
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
azuread | = 2.34.1

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`assignments`|The list of role assignments to this principal|list|`[]`
