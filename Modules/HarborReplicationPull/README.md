# Harbor Replication Module Pull

Terraform module for harbor replication - pull.

## Module Usage

```hcl
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "harbor-replication-pull" {
  # Creating harbor replications - pull
  source                              = "git::https://<git_address>/hce-public/modules.git//HarborReplicationPull"
  key_vault_name                      = "<keyvault_name>"
  acr_key_name                        = "az-acr-token"
  resource_group_name                 = "<resourcegroup_name>"
  key_vault_secret_name               = var.key_vault_secret_name
  harbor_project_url                  = var.harbor_project_url
  harbor_project_user_name            = "admin"
  harbor_registry_provider_name       = var.provider_name
  harbor_registry_name                = var.harbor_registry_name
  harbor_registry_endpoint_url        = var.harbor_registry_endpoint_url
  harbor_registry_access_id           = "1111-111-111-111-111111"
  harbor_registry_insecure            = var.harbor_registry_insecure
  harbor_replication_name             = var.harbor_replication_name
  harbor_replication_schedule         = var.harbor_replication_schedule
  harbor_replication_override         = var.harbor_replication_override
  harbor_replication_dest_namespace   = var.harbor_replication_dest_namespace
  harbor_replication_filters_name     = var.harbor_replication_filters_name
  harbor_replication_filters_tag      = var.harbor_replication_filters_tag
  harbor_replication_filters_resource = var.harbor_replication_filters_resource
}
```
variables
```
variable "key_vault_secret_name" {
  description = "key_vault_secret_name. Possible values are `harbor-stg` and `harbor-prod`"
  type        = string
  default     = "harbor-stg"
}

variable "harbor_project_url" {
  description = "harbor_project_url. Possible values are https://stg-harbor1.mydomain.com and https://prod-harbor1.mydomain.com"
  type        = string
  default     = "https://stg-harbor1.mydomain.com"
}

variable "provider_name" {
  description = "provider_name . Possible values are `alibaba`, `aws`, `azure`, `docker-hub`, `docker-registry`, `gitlab`, `google`, `harbor`, `helm`, `huawei`, `jfrog`"
  type        = string
  default     = "azure"
}

variable "harbor_registry_name" {
  description = "(Required) The name of the register"
  type        = string
  default     = "azure-pull-push-images-matrix"
}

variable "harbor_registry_endpoint_url" {
  description = "(Required) The url endpoint for the external container register ie, https://<my_registery>.azurecr.io"
  type        = string
  default     = "https://<my_registery>.azurecr.io"
}

variable "harbor_registry_insecure" {
  description = "(Optional) Verifies the certificate of the external container register. Can be set to `true` or `false`"
  type        = string
  default     = "false"
}

variable "harbor_replication_name" {
  description = "(Required) name of replication"
  type        = string
  default     = "replicate_example"
}

variable "harbor_replication_schedule" {
  description = "(Optional) The scheduled time of when the container register will be push / pull. In cron base format. Hourly `0 0 * * * *`, Daily `0 0 0 * * *`, Monthly `0 0 0 * * 0`"
  type        = string
  default     = "0 0 0 * * *"
}

variable "harbor_replication_override" {
  description = "(Optional) Specify whether to override the resources at the destination if a resources with the same name exist. Can be set to `true` or `false`"
  type        = string
  default     = "false"
}

variable "harbor_replication_dest_namespace" {
  description = "(Optional) Specify the destination namespace. if empty, the resource will be put under the same namespace as the source."
  type        = string
  default     = "hce"
}

variable "harbor_replication_filters_name" {
  description = "(Optional) A collection of filters block as documented below."
  type        = string
  default     = "hce/**"
}

variable "harbor_replication_filters_tag" {
  description = "(Optional) Filter on the tag/version of the resource"
  type        = string
  default     = "latest"
}

variable "harbor_replication_filters_resource" {
  description = "(Optional) Filter on the resource type. Can be one of the following types. `chart` or `artifact`"
  type        = string
  default     = "artifact"
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
`source` | The git URL of the repository | string | `""`
`key_vault_name` | The name of the KeyVault | string | `""`
`key_vault_secret_name` | The secret of the KeyVault | string | `""`
`acr_key_name` | Azure Container Registry Key name | string | `""`
`resource_group_name` | Name of the resource group inside Azure | string | `""`
`harbor_project_url` | URL of the Local Harbor instance | string | `""`
`harbor_project_user_name` | Local Harbor project username | string | `""`
`harbor_registry_provider_name` | Remote (Azure) registry provider name | string | `""`
`harbor_registry_name` | Remote registry name | string | `""`
`harbor_registry_endpoint_url` | Remote registry endpoint URL | string | `""`
`harbor_registry_access_id` | Remote registry access ID | string | `""`
`harbor_registry_insecure` | Remote registry insecure connection | string | `""`
`harbor_replication_name` | Harbor replication name | string | `""`
`harbor_replication_schedule` | Harbor replication schedule | string | `""`
`harbor_replication_override` | Harbor replication override | string | `""`
`harbor_replication_dest_namespace` | Harbor replication destination namespace | string | `""`
`harbor_replication_filters_name` | Harbor replication filters name | string | `""`
`harbor_replication_filters_tag` | Harbor replication filters tag | string | `""`
`harbor_replication_filters_resource` | Harbor replication filters resource | string | `""`