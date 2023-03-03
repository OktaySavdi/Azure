terraform {
  required_providers {
    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "1.1.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.3.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.44.1"
    }
  }
  required_version = ">= 1.1.9"
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}

#provider "local" {
#  # Configuration options
#}

#### Data sources ###
#data "azurerm_key_vault" "kv" {
#  name                = "<keyvault_name>"
#  resource_group_name = "<resourcegroup_name>"
#}
#
#data "azurerm_key_vault_secret" "api_token" {
#  name         = "tmc-api-token"
#  key_vault_id = data.azurerm_key_vault.kv.id
#}
####
#
#### Providers ###
#provider "tanzu-mission-control" {
#  endpoint            = "mycompanyiesgmbh.tmc.cloud.vmware.com"
#  vmw_cloud_api_token = data.azurerm_key_vault_secret.api_token.value
#}
####
