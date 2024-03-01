# Harbor Project Module

Terraform module for creating harbor projects.

## Module Usage

```hcl
module "harbor-project" {
  source                = "git::https://<git_address>/hce-public/modules.git//HarborProject?ref=v3.44.1"
  key_vault_secret_name = var.key_vault_secret_name

  harbor_project_name    = var.harbor_project_name
  define_group           = var.define_group
  image_retention_policy = var.image_retention_policy

  storage_quota       = var.storage_quota
  key_vault_name      = "azgwc-kv-gtit-hce-prod"
  resource_group_name = "azgwc-rg-gtit-hce-prod-01"
  harbor_project_url  = var.harbor_project_url
}
```
variables
```hcl
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

variable "harbor_project_name" {
  default = {
    name                   = "test" # (Required) The of the project that will be created in harbor (must be lowercase).
    public                 = false  # (Optional) The project will be public accessibility. Can be set to "true" or "false"
    vulnerability_scanning = false  # (Optional) Images will be scanned for vulnerabilities when push to harbor. Can be set to "true" or "false"
    enable_content_trust   = false  # (Optional) Enables Content Trust for project. When enabled it queries the embedded docker notary server. Can be set to "true" or "false" (Default:
  }
}

variable "define_group" {
  type = list(object({
    group_name    = string   
    role          = string
    ldap_group_dn = string
    type          = string
  }))

  default = [
    {
      group_name    = "<my group name>"                                           # (Required) The of the project that will be created in harbor (must be lowercase).
      type          = "ldap"                                                      # (Required) The group type. Can be set to "ldap", "internal" or "oidc"
      role          = "developer"                                                 # (Required) The premissions that the entity will be granted.
      ldap_group_dn = "CN=<my_CN>,OU=RoleGroups,OU=<my_OU>,DC=<my_DC>,DC=<my_DC>" # The distinguished name of the group within AD/LDAP
    },
    {
      group_name    = "<my group name>"
      type          = "ldap"
      role          = "projectadmin"
      ldap_group_dn = "CN=<my_CN>,OU=RoleGroups,OU=<my_OU>,DC=<my_DC>,DC=<my_DC>"
    }
  ]
}

variable "image_retention_policy" { #Description of policies https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/retention_policy
  default = [
    {
      n_days_since_last_pull = 5
      repo_matching          = "**"
      tag_matching           = "latest"
      schedule               = "Daily"
      disabled               = false
      always_retain          = false
      repo_excluding         = null
      tag_excluding          = null
      untagged_artifacts     = false
      n_days_since_last_push = null
      most_recently_pulled   = null
      most_recently_pushed   = null
    },
	  {
	    n_days_since_last_push = 10
      repo_matching          = "**"
      tag_matching           = "{latest,snapshot}"
      schedule               = "Daily"
      disabled               = false
      always_retain          = false
      repo_excluding         = null
      tag_excluding          = null
      untagged_artifacts     = false
      n_days_since_last_pull = null
      most_recently_pulled   = null
      most_recently_pushed   = null
	  }
  ]
}
```
providers.tf
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
}
```
## Resources

| Name | Type |
|------|------|
| [harbor_project.harborproject](https://registry.terraform.io/providers/BESTSELLER/harbor/3.7.1/docs/resources/project) | resource |
| [harbor_project_member_group.harborprojectmembergroup](https://registry.terraform.io/providers/BESTSELLER/harbor/3.7.1/docs/resources/project_member_group) | resource |
| [harbor_retention_policy.main](https://registry.terraform.io/providers/BESTSELLER/harbor/3.7.1/docs/resources/retention_policy) | resource |
| [azurerm_key_vault.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.harbor_token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_define_group"></a> [define\_group](#input\_define\_group) | n/a | <pre>list(object({<br>    group_name    = string<br>    role          = string<br>    ldap_group_dn = string<br>    type          = string<br>  }))</pre> | n/a | yes |
| <a name="input_harbor_project_name"></a> [harbor\_project\_name](#input\_harbor\_project\_name) | For each project, create an object that contain fields | `map` | `{}` | no |
| <a name="input_harbor_project_url"></a> [harbor\_project\_url](#input\_harbor\_project\_url) | URL of harbor project | `string` | n/a | yes |
| <a name="input_image_retention_policy"></a> [image\_retention\_policy](#input\_image\_retention\_policy) | n/a | <pre>list(object({<br>    enabled                = bool<br>    schedule               = string<br>    disabled               = bool<br>    n_days_since_last_pull = number<br>    tag_matching           = string<br>    always_retain          = bool<br>    repo_matching          = string<br>    repo_excluding         = string<br>    tag_excluding          = string<br>    untagged_artifacts     = bool<br>  }))</pre> | `[]` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | name of key vault resource | `string` | n/a | yes |
| <a name="input_key_vault_secret_name"></a> [key\_vault\_secret\_name](#input\_key\_vault\_secret\_name) | azure prod env name of vault | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | resource group name of key vault | `string` | n/a | yes |
| <a name="input_storage_quota"></a> [storage\_quota](#input\_storage\_quota) | harbor registry repo size information example: 5 | `string` | n/a | yes |



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
