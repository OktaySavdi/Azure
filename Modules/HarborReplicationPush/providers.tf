terraform {
  required_providers {
    harbor = {
      source  = "BESTSELLER/harbor"
      version = "3.7.1"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}

### Data sources ###
data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "harbor_token" {
  name         = var.key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
}


###
provider "harbor" {
  url      = var.harbor_project_url
  username = var.harbor_project_user_name
  password = data.azurerm_key_vault_secret.harbor_token.value
  insecure = true
}
