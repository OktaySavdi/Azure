# Virtual Network Module

Terraform module used to create following resourses.
1. Service plan
2. Linux functipn app


## Module Usage

**main.tf**
```hcl
# main.tf configuration
module "function_app" {
  source                          = "git::https://myrepo.lan/modules.git//funtion_app_linux?ref=v3.44.1"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  vnet_name                       = var.vnet_name
  subnet_name                     = var.subnet_name
  network_resource_group_name     = var.network_resource_group_name
  storage_account_name            = var.storage_account_name
  service_plan_name               = var.service_plan_name
  sku_name                        = var.sku_name
  function_name                   = var.function_name
  site_config                     = var.site_config
  tags                            = var.default_tags
}
```
**variables.tf**
```hcl
variable "default_tags" {
  type = map(any)
  default = {
    Owner         		  = "hce"
    Platform      		  = "HCE"
    Environment   		  = "prod"
  }
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "az-rg-di-function-app-prod-01"
}

variable "location" {
  description = "The location/region to keep all your network resources."
  default     = "germanywestcentral"
}

variable "vnet_name" {
  description = "Name of Azure Virtual Network"
  default     = "az-vnet-myapp-prod-01"
}

variable "network_resource_group_name" {
  description = "network resource group name"
  default     = "az-rg-myapp-network-prod-01"
}

variable "storage_account_name" {
  description = "Storage account name"
  default     = "azstdifnappprod01"
}

variable "storage_primary_access_key"{
  description = "storage account primary access key"
  default     = ""
}

variable "service_plan_name" {
  description = "service plan name"
  default     = "az-asp-function-app-prod-01"
}

variable "subnet_name" {
  description = "subnet name"
  default     = "az-snet-myapp-prod-01"
}

variable "sku_name"{
  description = "Service plan name"
  default     = "B1"
}

variable "function_name"{
  description = "Service plan name"
  default     = "az-fn-di-prod-01"
}

variable "stor"{
  description = "Service plan name"
  default     = "az-fn-di-prod-01"
}

variable "site_config" {
  description = "For each subnet, create an object that contain fields"
  default     = {
    test ={
      always_on = true
      http2_enabled = true
      application_stack = {
        python_version = "3.9"
      }
    }
  }
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
`location`|The location in which resources are created| string | `""`
`vnet_name`|The name of the virtual network| string | `""`
`network_resource_group_name`|Virtual Network resource group name |string| `""`
`storage_account_name` | Strorage account name for function app | string | `""`
`storage_account_name` | storage account primary access key | string | `""`
`service_plan_name`|Service plan name|string| `""`
`subnet_name`|subnet name to associate service plan |string| `""`
`sku_name`|The SKU for the plan. Possible values include B1, B2, B3, D1, F1, P1, P2, P3, P1v2, P2v2, P3v2, P1v3, P2v3, P3v3, S1, S2, S3 and PDV3. |string| `""`
`function_name`|function app name | string | `""`
`site_config`|Site config for Function App. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#site_config. IP restriction attribute is not managed in this block. |map|`{}`
## Outputs

|Name | Description|
|---- | -----------|
`virtual_network_name` | The name of the virtual network.
`virtual_network_id` |The virtual NetworkConfiguration ID.
`network_security_group_ids`|List of Network security groups and ids

## Other resources

* [ Naming Convention & Tagging](https://confluence.gtoffice.lan/pages/viewpage.action?pageId=349909882)
