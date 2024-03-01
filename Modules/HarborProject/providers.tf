terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.8"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  alias           = "keyvault-sub"
  subscription_id = "<sub_id>"
  tenant_id       = "<tenant_id>"
  features {}
}

### Data sources ###
data "azurerm_key_vault" "kv" {
  provider            = azurerm.keyvault-sub
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "harbor_token" {
  provider     = azurerm.keyvault-sub
  name         = var.key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

###
provider "harbor" {
  url      = var.harbor_project_url
  username = "admin"
  password = data.azurerm_key_vault_secret.harbor_token.value
  insecure = true
}
