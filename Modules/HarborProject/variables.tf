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

variable "storage_quota" {
  type        = string
  description = "harbor registry repo size information example: 5"

  validation {
    condition     = var.storage_quota < 200
    error_message = "`storage_quota` must be less than 200 GB"
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
  type = list(object({
    schedule               = string
    disabled               = bool
    tag_matching           = string
    always_retain          = bool
    repo_matching          = string
    repo_excluding         = string
    tag_excluding          = string
    untagged_artifacts     = bool
    n_days_since_last_pull = number
    n_days_since_last_push = number
    most_recently_pulled   = number
    most_recently_pushed   = number
  }))
  default = []
}

variable "define_group" {
  type = list(object({
    group_name    = string
    role          = string
    ldap_group_dn = string
    type          = string
  }))
}

variable "harbor_project_name" {
  description = "For each project, create an object that contain fields"
  default     = {}
}
