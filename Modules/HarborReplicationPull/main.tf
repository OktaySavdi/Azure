data "azurerm_key_vault_secret" "azure_token" {
  name         = var.acr_key_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "harbor_registry" "harborregistry" {
  provider_name = var.harbor_registry_provider_name
  name          = var.harbor_registry_name
  endpoint_url  = var.harbor_registry_endpoint_url
  access_id     = var.harbor_registry_access_id
  access_secret = data.azurerm_key_vault_secret.azure_token.value
  insecure      = var.harbor_registry_insecure
}

resource "harbor_replication" "pull" {
  name           = var.harbor_replication_name
  action         = "pull" ## Value should not be changed
  registry_id    = harbor_registry.harborregistry.registry_id
  schedule       = var.harbor_replication_schedule
  override       = var.harbor_replication_override
  dest_namespace = var.harbor_replication_dest_namespace
  filters {
    name = var.harbor_replication_filters_name
  }
  filters {
    tag = var.harbor_replication_filters_tag
  }
  filters {
    resource = var.harbor_replication_filters_resource
  }
}
