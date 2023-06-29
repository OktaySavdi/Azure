variable "harbor_project_name" {
  description = "harbor project name"
  type        = string
}

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
  description = "azure prod env name of vault"
  type = list(object({
    group_name    = string
    role          = string
    ldap_group_dn = string
  }))
  default = []
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

