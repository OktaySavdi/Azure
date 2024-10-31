**main.tf**
```hcl
module "Resource_Groups" {
  source = "git::https://<myrepo>/modules.git//Resource_Group?ref=v3.114.0"

  rg = [
    {
      name                = "azci-rg-<myteam>-storage-nonprod-01"
      location            = "centralindia"
      tags = {
        Owner              = "myteam1@mydomain.com"
        Environment        = "nonprod"
      }
    },
    {
      name                = "azgwc-rg-<myteam>-storage-nonprod-01"
      location            = "germanywestcentral"
      tags = {
        Owner              = "myteam1@mydomain.com"
        Environment        = "nonprod"
      }
    },
    {
      name                = "azwus3-rg-<myteam>-storage-nonprod-01"
      location            = "westus3"
      tags = {
        Owner              = "myteam1@mydomain.com"
        Environment        = "nonprod"
      }
    },
    {
      name                = "az-rg-<myteam>-nonprod-01"
      location            = "germanywestcentral"
      tags = {
        DataClassification = "internal"
        Owner              = "myteam1@mydomain.com"
        Environment        = "nonprod"
      }
    }
  ]
}
```
**variables.tf**
```hcl
variable "logic_app" {
  description = "The list of role assignments to this service principal"
  type = list(object({
    name         = string
    locations    = string
    tags         = map(string)
  }))
  default = []
}
```
**outputs.tf**
```hcl
output "all_resource_group_ids" {
  value = module.rg.resource_group_ids
}

output "all_resource_group_names" {
  value = module.rg.resource_group_names
}

output "all_resource_group_locations" {
  value = module.rg.resource_group_locations
}
```
**providers.tf**
```hcl
# providers.tf configuration
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.114.0"
    }
  }
    backend "azurerm" {
      resource_group_name  = "<rg>"
      storage_account_name = "<sa>"
      container_name       = "<cn>"
      key                  = "/subscription/<>/nonprod/ResourceGroups/terraform.tfstate"
    }
}

provider "azurerm" {
  subscription_id = "xxxxx-xxxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx"
  tenant_id       = "xxxxx-xxxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx"
  features {}
}
```

## Requirements

Name | Version
-----|--------
terraform | >= 1.9.3
azurerm | = 3.114.0

## Providers

| Name | Version |
|------|---------|
azurerm | = 3.114.0
