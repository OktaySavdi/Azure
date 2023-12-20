# Logic Apps Module

Terraform module for Logic Apps

## Module Usage

**main.tf**
```hcl
module "Logic_apps" {
  source = "git::https://<repo_address>/public/modules.git//Logic_Apps"

  logic_app = [
    {
      logic_app_name      = "az-la-hce-test-01"
      resource_group_name = "az-rg-hce-test-01"
      location            = "westeurope"
      workflow_version    = "1.0.0.0"
      workflow_schema     = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
      tags = {
        "DataClassification" = "internal"
        "Owner"              = "hce"
        "Platform"           = "it"
        "Environment"        = "nonprod"
      }
    },
    {
      logic_app_name      = "az-la-hce-test-02"
      resource_group_name = "az-rg-hce-test-01"
      location            = "germanywestcentral"
      workflow_version    = "1.0.0.0"
      workflow_schema     = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
      tags = {
        "DataClassification" = "internal"
        "Owner"              = "hce"
        "Platform"           = "it"
        "Environment"        = "nonprod"
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
    logic_app_name      = string
    workflow_version    = string
    workflow_schema     = string
    location            = string
    resource_group_name = string
    tags                = map(string)
  }))
  default = []
}
```
**outputs.tf**
```
output "logic_app_name" {
  value = module.Logic_apps.logic_app_name
}

output "logic_app_location" {
  value = module.Logic_apps.logic_app_location
}

output "id" {
  value = module.Logic_apps.id
}

output "workflow_versions" {
  value = module.Logic_apps.workflow_versions
}
```
**providers.tf**
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.44.1"
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
    subscription_id = "xxxxx-xxx-xxxxx-xxxxxx-xxxxx"
    tenant_id       = "xxxxx-xxx-xxxxx-xxxxxx-xxxxx"
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

## Other resources

* [ Naming Convention & Tagging](https://confluence.gtoffice.lan/pages/viewpage.action?pageId=349909882)

## Inputs

| Name                                                                                            | Description                                              | Type           | Required |
|-------------------------------------------------------------------------------------------------|----------------------------------------------------------|----------------|----------|
| <a name="input_location"></a> [location](#input\_location)                                      | Location                                                 | `string`       |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                  | Logic app name                                           | `string`       |   yes    |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group)                  | Resource group name                                      | `string`       |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                  | Tags                                                     | `map(string)`  |   yes    |
| <a name="input_workflow_versions"></a> [workflow\_version](#input\_workflow\_version)           | workflow_versions                                        | `string`       |    yes   |
| <a name="input_workflow_schema"></a> [workflow\_schema  ](#input\_workflow\_workspace\_schema)  | Specifies the Schema to use for this Logic App Workflow. | `string`       |    yes   |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Logic App. |
| <a name="logic_app_location"></a> [location](#output\_logic_app_location) | Function app logic_app_location |
| <a name="workflow_versions"></a> [versions](#output\_workflow_versions) | Function app workflow_versions |
| <a name="logic_app_name"></a> [name](#output\_logic_app_name) | Function app logic_app_name |
<!-- END_TF_DOCS -->
