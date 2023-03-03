variable "key_vault_secret_name" {
  type        = string
  description = "azure prod env name of vault"

  validation {
    condition = var.key_vault_name == null ? true : contains([
      "harbor-stg", "harbor-prod"
    ], var.key_vault_name)
    error_message = "`key_vault_name`'s possible values are `harbor-stg`, `harbor-prod`"
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
    condition     = var.storage_quota >= 20
    error_message = "`storage_quota` must be less than 20 GB"
  }
}

variable "image_retention_policy" {
  type        = map(string)
  description = "information about retantion policy"

  validation {
    condition = var.image_retention_policy == null ? true : contains([
      "daily", "weekly", "monthly"
    ], var.image_retention_policy)
    error_message = "`image_retention_policy`'s possible values are `daily`, `weekly`, `monthly`"
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

variable "harbor_project_user_name" {
  type        = string
  description = "username to access harbor project url"

  validation {
    condition = var.public == null ? true : contains([
      "true", "false"
    ], var.public)
    error_message = "`public`'s possible values are `true`, `false`"
  }

  validation {
    condition = var.vulnerability_scanning == null ? true : contains([
      "true", "false"
    ], var.vulnerability_scanning)
    error_message = "`vulnerability_scanning`'s possible values are `true`, `false`"
  }
}