# Service Principal Module

Terraform module to create a service principal and assign required roles. The outputs from this module, like client_id, can be used as an input in other modules.

## Module Usage

```hcl
# main.tf configuration
provider "azurerm" {
  features {}
}

module "service_principal" {
  source  = "git::https://<git_address>/hce-public/modules.git//ServicePrincipal"

  service_principal_name   = var.service_principal_name
  service_principal_owner  = var.service_principal_owner

  # Adding roles and scope to service principal
  assignments = var.assignments
}
```

```hcl
# variables configuration

variable "service_principal_name" {
  description = "The name of the service principal"
  type        = string
  default     = "az-sp-hce-aks-prod-01"
}

variable "service_principal_owner" {
  description = "A set of object IDs of principals that will be granted ownership of both the AAD Application and associated Service Principal. Supported object types are users or service principals."
  type        = list(string)
  default     = ["111-1111-11-111-1111", "2222-222-222-222-22222"]
}

variable "assignments" {
  description = "The list of role assignments to this service principal"
  type = list(object({
    scope                = string
    role_definition_name = string
  }))
  default = [
    {
      scope                = "/subscriptions/<subscription_ID>/resourceGroups/<resourcegroup_name>"
      role_definition_name = "Contributor"
    },
    {
      scope                = "/subscriptions/<subscription_ID>/resourceGroups/<privatedns_resourcegroup_name>/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
      role_definition_name = "Private DNS Zone Contributor"
    }
  ]
}

```

```hcl
# output configuration

output "service_principal_name" {
  description = "The name of service principal."
  value       = module.service_principal.service_principal_name
}

output "service_principal_owner" {
  description = "The name of owner for service principal."
  value       = module.service_principal.service_principal_owner
}

output "service_principal_object_id" {
  description = "The object id of service principal."
  value       = module.service_principal.service_principal_object_id
}

output "client_id" {
  description = "The application id of AzureAD application created."
  value       = module.service_principal.client_id
}

output "client_secret" {
  description = "Password for service principal."
  value       = module.service_principal.client_secret
  sensitive   = true
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
`service_principal_name` | The name of the service principal| string | `""`
`assignments`|The list of role assignments to this service principal|list|`[]`

## Outputs

|Name | Description|
|---- | -----------|
`service_principal_name`|The name of the service principal
`service_principal_object_id`|The object id of service principal.
`client_id`|The client id of service principal
`client_secret`|The Client secert for service principal
