# Role Assignement Module

Terraform module for assigning role to different type of principals.

## Module Usage

```hcl
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "az_public_ip" {
  source              = "git::https://<git_address>/hce-public/modules.git//PublicIP"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  # Adding roles and scope to service principal
  public_ip = [
    {
      name                = "acceptanceTestPublicIp1"
      allocation_method   = "Static"
      sku                 = "Standart"
    },
    {
      name                = "acceptanceTestPublicIp1"
      allocation_method   = "Static"
      sku                 = "Basic"
    }
  ]
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
`assignments`|The list of role assignments to this principal|list|`[]`