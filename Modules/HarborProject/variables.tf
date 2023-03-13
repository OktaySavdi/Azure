variable "key_vault_secret_name" {
  type        = string
  description = "azure prod env name of vault"

  validation {
    condition = var.key_vault_secret_name == null ? true : contains([
      "harbor-stg", "harbor-prod"
    ], var.key_vault_secret_name)
    error_message = "`key_vault_secret_name`'s possible values are `harbor-stg`, `harbor-prod`"
  }
}

variable "define_group" {
  type        = map(any)
  description = "azure prod env name of vault"
}

variable "harbor_project_name" {
  type        = map(string)
  description = "name of harbor project"
}

variable "storage_quota" {
  type        = string
  description = "harbor registry repo size information example: 5"

  validation {
    condition     = var.storage_quota < 20
    error_message = "`storage_quota` must be less than 20 GB"
  }
}

variable "key_vault_name" {
  type        = string
  description = "name of key vault resource"
}

variable "resource_group_name" {
  type        = string
  description = "resource group name of key vault"
}

variable "harbor_project_url" {
  type        = string
  description = "URL of harbor project"
}

variable "image_retention_policy" {
  type        = map(string)
  description = "information about retantion policy"
}
