**terraform.tfvars**
```hcl
resource_group_name = "az-rg-hce-acr-prod-01"
location            = "germanywestcentral"

# Azure Container Registry configuration
# The `Classic` SKU is Deprecated and will no longer be available for new resources
container_registry_config = {
  name          = "containerregistry01"
  admin_enabled = false
  sku           = "Premium"
}

# Content trust is a feature of the Premium service tier of Azure Container Registry.
enable_content_trust = true

# Creating Private Endpoint requires
virtual_network_name          = "az-vnet-hce-acr-prod-01"
subnet_name                   = "az-snet-hce-acr-prod-01"
network_resource_group        = "az-rg-hce-acr-prod-01"

# Set a retention policy with care--deleted image data is UNRECOVERABLE.
# A retention policy for untagged manifests is currently a preview feature of Premium container registries
# The retention policy applies only to untagged manifests with timestamps after the policy is enabled. Default is `7` days.
retention_policy = {
  days    = 10
  enabled = true
}

# The georeplications is only supported on new resources with the Premium SKU.
# The georeplications list cannot contain the location where the Container Registry exists.
georeplications = [
  #{
  #  location                = "northeurope"
  #  zone_redundancy_enabled = true
  #},
  #{
  #  location                = "francecentral"
  #  zone_redundancy_enabled = false
  #}
]

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
module "container-registry" {
  source  = "git::https://myrepo.mydomain.lan/modules.git//ACR?ref=v3.97.1"

  resource_group_name           = var.resource_group_name
  location                      = var.location
  container_registry_config     = var.container_registry_config
  georeplications               = var.georeplications
  retention_policy              = var.retention_policy
  enable_content_trust          = var.enable_content_trust
  virtual_network_name          = var.virtual_network_name
  subnet_name                   = var.subnet_name
  enable_private_endpoint       = var.enable_private_endpoint
  network_resource_group        = var.network_resource_group
  tags = var.tags
}
```
**Providers.tf**
```
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
  subscription_id = "xxx-xxx-xxx-xxx-xxx"
  tenant_id       = "xxx-xxx-xxx-xxx-xxx"
  features {}
}
```
**variables.tf**
```
variable "location" {
  description = "Specifies the Azure Region where the Virtual Machine exists. Changing this forces a new resource to be created"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Specifies the name of the Resource Group in which the Virtual Machine should exist. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "network_resource_group" {
  description = "Specifies the name of the Resource Group in which the Network should exist"
  type        = string
  default     = ""
}

variable "enable_content_trust" {
  description = "(Optional) Boolean value that indicates whether the policy is enabled."
  type        = bool
}

variable "enable_private_endpoint" {
  description = "(Optional) Boolean value that indicates enable_private_endpoint enabled."
  type        = bool
  default     = true
}

variable "virtual_network_name" {
  description = "(Optional)Define the virtual_network_name for private endpoint"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "(Optional) Define the subnet_name for private endpoint"
  type        = string
  default     = ""
}

variable "container_registry_config" {
  description = "For each container_registry_config, create an object that contain fields"
  default     = {}
}

variable "georeplications" {
  description = "For each georeplications, create an object that contain fields"
  default     = {}
}

variable "retention_policy" {
  description = "For each retention_policy, create an object that contain fields"
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.97.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_registry_config"></a> [container\_registry\_config](#input\_container\_registry\_config) | For each container\_registry\_config, create an object that contain fields | `map` | `{}` | no |    
| <a name="input_enable_content_trust"></a> [enable\_content\_trust](#input\_enable\_content\_trust) | (Optional) Boolean value that indicates whether the policy is enabled. | `bool` | n/a | yes |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | (Optional) Boolean value that indicates enable\_private\_endpoint enabled. | `bool` | `true` | no |       
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | For each georeplications, create an object that contain fields | `map` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the Azure Region where the Virtual Machine exists. Changing this forces a new resource to be created | `string` | `""` | no |
| <a name="input_network_resource_group"></a> [network\_resource\_group](#input\_network\_resource\_group) | Specifies the name of the Resource Group in which the Network should exist | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the name of the Resource Group in which the Virtual Machine should exist. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_retention_policy"></a> [retention\_policy](#input\_retention\_policy) | For each retention\_policy, create an object that contain fields | `map` | `{}` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | (Optional) Define the subnet\_name for private endpoint | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map` | `{}` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Optional)Define the virtual\_network\_name for private endpoint | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_registry_admin_password"></a> [container\_registry\_admin\_password](#output\_container\_registry\_admin\_password) | The Username associated with the Container Registry Admin account - if the admin account is enabled. |
| <a name="output_container_registry_admin_username"></a> [container\_registry\_admin\_username](#output\_container\_registry\_admin\_username) | The Username associated with the Container Registry Admin account - if the admin account is enabled. |
| <a name="output_container_registry_id"></a> [container\_registry\_id](#output\_container\_registry\_id) | The ID of the Container Registry |
| <a name="output_container_registry_identity_principal_id"></a> [container\_registry\_identity\_principal\_id](#output\_container\_registry\_identity\_principal\_id) | The Principal ID for the Service Principal associated with the Managed Service Identity of this Container Registry |
| <a name="output_container_registry_identity_tenant_id"></a> [container\_registry\_identity\_tenant\_id](#output\_container\_registry\_identity\_tenant\_id) | The Tenant ID for the Service Principal associated with the Managed Service Identity of this Container Registry |
| <a name="output_container_registry_login_server"></a> [container\_registry\_login\_server](#output\_container\_registry\_login\_server) | The URL that can be used to log into the container registry |
| <a name="output_container_registry_private_endpoint"></a> [container\_registry\_private\_endpoint](#output\_container\_registry\_private\_endpoint) | id of the Azure Container Registry Private Endpoint |
| <a name="output_container_registry_scope_map_id"></a> [container\_registry\_scope\_map\_id](#output\_container\_registry\_scope\_map\_id) | The ID of the Container Registry scope map |
| <a name="output_container_registry_token_id"></a> [container\_registry\_token\_id](#output\_container\_registry\_token\_id) | The ID of the Container Registry token |
| <a name="output_container_registry_webhook_id"></a> [container\_registry\_webhook\_id](#output\_container\_registry\_webhook\_id) | The ID of the Container Registry Webhook |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The id of the resource group in which resources are created |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | The location of the resource group in which resources are created |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group in which resources are created |
