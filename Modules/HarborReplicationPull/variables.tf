variable "key_vault_name" {
  type        = string
  description = "name of key vault resource"
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

variable "acr_key_name" {
  type        = string
  description = "azure prod env name of vault"
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
}

## Harbor Registry - Variables

variable "harbor_registry_provider_name" {
  type        = string
  description = "harbor registry provider name"

  validation {
    condition = var.harbor_registry_provider_name == null ? true : contains([
      "alibaba", "aws", "azure", "docker-hub", "docker-registry", "gitlab", "google", "harbor", "helm", "huawei", "jfrog"
    ], var.harbor_registry_provider_name)
    error_message = "`harbor_registry_provider_name`'s possible values are `alibaba`, `aws`, `azure`, `docker-hub`, `docker-registry`, `gitlab`, `google`, `harbor`, `helm`, `huawei`, `jfrog`"
  }
}

variable "harbor_registry_name" {
  type        = string
  description = "harbor registry name"
}

variable "harbor_registry_endpoint_url" {
  type        = string
  description = "harbor registry endpoint url"
}

variable "harbor_registry_access_id" {
  type        = string
  description = "harbor registry access id"
}

variable "harbor_registry_insecure" {
  type        = string
  description = "harbor registry insecure connection"

  validation {
    condition = var.harbor_registry_insecure == null ? true : contains([
      "true", "false"
    ], var.harbor_registry_insecure)
    error_message = "`harbor_registry_insecure`'s possible values are `true`, `false`"
  }
}

## Harbor Replication - Pull - Variables

variable "harbor_replication_name" {
  type        = string
  description = "harbor replication name"
}

variable "harbor_replication_schedule" {
  type        = string
  description = "harbor replication schedule"
}

variable "harbor_replication_override" {
  type        = string
  description = "harbor replication override - true or false"

  validation {
    condition = var.harbor_replication_override == null ? true : contains([
      "true", "false"
    ], var.harbor_replication_override)
    error_message = "`harbor_replication_override`'s possible values are `true`, `false`"
  }
}

variable "harbor_replication_dest_namespace" {
  type        = string
  description = "harbor replication destination namespace"
}

variable "harbor_replication_filters_name" {
  type        = string
  description = "harbor replication filters name"
}

variable "harbor_replication_filters_tag" {
  type        = string
  description = "harbor replication filters tag"
}

variable "harbor_replication_filters_resource" {
  type        = string
  description = "harbor replication filters resource"

  validation {
    condition = var.harbor_replication_filters_resource == null ? true : contains([
      "chart", "artifact"
    ], var.harbor_replication_filters_resource)
    error_message = "`harbor_replication_filters_resource`'s possible values are `chart`, `artifact`"
  }
}