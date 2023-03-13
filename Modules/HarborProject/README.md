# Harbor Project Module

Terraform module for creating harbor projects.

## Module Usage

```hcl
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "harbor-project" {
  source                = "git::https://ato-hce-git1.gtoffice.lan/hce-public/modules.git//HarborProject"
  key_vault_secret_name = var.key_vault_secret_name

  define_group = {
    group1 = {
      group_name    = var.define_group.group_name
      role          = var.define_group.role
      ldap_group_dn = var.define_group.ldap_group_dn
    }
  }

  harbor_project_name = {
    "name"                   = var.harbor_project_name.name
    "public"                 = var.harbor_project_name.public
    "vulnerability_scanning" = var.harbor_project_name.vulnerability_scanning
  }

  image_retention_policy = {
    "disabled"               = var.image_retention_policy.disabled
    "schedule"               = var.image_retention_policy.schedule
    "n_days_since_last_pull" = var.image_retention_policy.n_days_since_last_pull
    "n_days_since_last_push" = var.image_retention_policy.n_days_since_last_push
    "tag_matching"           = var.image_retention_policy.tag_matching
  }

  storage_quota            = var.storage_quota
  key_vault_name           = "azgwc-kv-gtit-hce-prod"
  resource_group_name      = "azgwc-rg-gtit-hce-prod-01"
  harbor_project_url       = var.harbor_project_url
}
```
variables
```
variable key_vault_secret_name {
  description   = "key_vault_secret_name. Possible values are harbor-stg and harbor-prod"
  type          = string
  default       = "harbor-stg"
}

variable storage_quota {
  description   = "The storage quota of the project in GB's"
  type          = number
  default       = 5
}

variable harbor_project_url {
  description   = "harbor_project_url. Possible values are https://stg-harbor1.domain.com and https://prod-harbor1.domain.com"
  type          = string
  default       = "https://stg-harbor1.domain.com"
}

variable "define_group" {
  type = map(string)
  default = {
    "group_name"            = "<my group name>"        # (Required) The of the project that will be created in harbor (must be lowercase).
    "role"                  = "projectadmin"           # (Required) The premissions that the entity will be granted.
    "ldap_group_dn"         = "CN=<my_CN>,OU=RoleGroups,OU=<my_OU>,DC=<my_DC>,DC=<my_DC>" # The distinguished name of the group within AD/LDAP
  }
}

variable "harbor_project_name" {
  type = map(string)
  default = {
    "name"                   = "<repo name>"     # (Required) The of the project that will be created in harbor (must be lowercase).
    "public"                 = true              # (Optional) The project will be public accessibility. Can be set to "true" or "false"
    "vulnerability_scanning" = true              # (Optional) Images will be scanned for vulnerabilities when push to harbor. Can be set to "true" or "false"
  }
}

variable "image_retention_policy" {
  type = map(string)
  default = {
    "disabled"                  = false     # (Optional) Specify if the rule is disable or not. Defaults to false
    "schedule"                  = "weekly"  # (Optional) The schedule of when you would like the policy to run. This can be daily, weekly, monthly or can be a custom cron string.
    "n_days_since_last_pull"    = 60        # (Optional) retains the artifacts pulled within the lasts n days.  
    "n_days_since_last_push"    = 60        # (Optional) retains the artifacts pushed within the lasts n days.
    "tag_matching"              = ""        # (Optional) For the tag excuding.
  }
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
`harbor-projects`|The list of harbor projects`[]`
