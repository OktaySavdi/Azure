locals {
  timestamp  = timestamp()
  start_date = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", local.timestamp)
  end_date   = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timeadd(local.start_date, "1h"))
}

resource "azurerm_storage_account" "storeacc" {
  name                            = var.storage_account_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_kind                    = var.account_kind
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public //do not allow public blobs for example

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  blob_properties {
    delete_retention_policy {
      days = 90
    }
    versioning_enabled = true
    container_delete_retention_policy {
      days = 90
    }

    dynamic "cors_rule" {
      for_each = var.cors_rule != null ? ["true"] : []
      content {
        allowed_origins    = var.cors_rule.allowed_origins
        allowed_methods    = var.cors_rule.allowed_methods
        allowed_headers    = var.cors_rule.allowed_headers
        exposed_headers    = var.cors_rule.exposed_headers
        max_age_in_seconds = var.cors_rule.max_age_in_seconds
      }
    }
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "pe-st" {
  name                = var.private_endpoint_name
  location            = var.private_endpoint_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = var.private_dns_zone_group_name
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  private_service_connection {
    name                           = "665465-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.storeacc.id
    is_manual_connection           = false
    subresource_names              = var.subresource_names
  }

  tags = var.tags

  depends_on = [
    azurerm_storage_account.storeacc,
    azurerm_storage_container.container
  ]
}

#--------------------------------------
# Storage Advanced Threat Protection 
#--------------------------------------
resource "azurerm_advanced_threat_protection" "atp" {
  target_resource_id = azurerm_storage_account.storeacc.id
  enabled            = var.enable_advanced_threat_protection
}

#-------------------------------
# Storage Container Creation
#-------------------------------
resource "azurerm_storage_container" "container" {
  count                 = length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = azurerm_storage_account.storeacc.name
  container_access_type = var.containers_list[count.index].access_type

  depends_on = [
    azurerm_storage_account.storeacc
  ]
}

#-------------------------------
# Storage Fileshare Creation
#-------------------------------
resource "azurerm_storage_share" "fileshare" {
  count                = length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.storeacc.name
  quota                = var.file_shares[count.index].quota

  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"
    access_policy {
      permissions = "rwdl"
      start       = local.start_date
      expiry      = local.end_date
    }
  }

  depends_on = [
    azurerm_storage_account.storeacc
  ]
}

#-------------------------------
# Storage Tables Creation
#-------------------------------
resource "azurerm_storage_table" "tables" {
  count                = length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = azurerm_storage_account.storeacc.name

  depends_on = [
    azurerm_storage_account.storeacc
  ]
}

#-------------------------------
# Storage Queue Creation
#-------------------------------
resource "azurerm_storage_queue" "queues" {
  count                = length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = azurerm_storage_account.storeacc.name

  depends_on = [
    azurerm_storage_account.storeacc
  ]
}
