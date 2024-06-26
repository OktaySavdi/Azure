locals {
  access_policies = [
    for p in var.access_policies : merge({
      azure_ad_group_names             = []
      object_ids                       = []
      azure_ad_user_principal_names    = []
      certificate_permissions          = []
      key_permissions                  = []
      secret_permissions               = []
      storage_permissions              = []
      azure_ad_service_principal_names = []
    }, p)
  ]

  azure_ad_group_names             = distinct(flatten(local.access_policies[*].azure_ad_group_names))
  azure_ad_user_principal_names    = distinct(flatten(local.access_policies[*].azure_ad_user_principal_names))
  azure_ad_service_principal_names = distinct(flatten(local.access_policies[*].azure_ad_service_principal_names))

  group_object_ids = { for g in data.azuread_group.adgrp : lower(g.display_name) => g.id }
  user_object_ids  = { for u in data.azuread_user.adusr : lower(u.user_principal_name) => u.id }
  spn_object_ids   = { for s in data.azuread_service_principal.adspn : lower(s.display_name) => s.id }

  flattened_access_policies = concat(
    flatten([
      for p in local.access_policies : flatten([
        for i in p.object_ids : {
          object_id               = i
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_group_names : {
          object_id               = local.group_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_user_principal_names : {
          object_id               = local.user_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_service_principal_names : {
          object_id               = local.spn_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ])
  )

  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }

  combined_access_policies = [
    for k, v in local.grouped_access_policies : {
      object_id               = k
      certificate_permissions = distinct(flatten(v[*].certificate_permissions))
      key_permissions         = distinct(flatten(v[*].key_permissions))
      secret_permissions      = distinct(flatten(v[*].secret_permissions))
      storage_permissions     = distinct(flatten(v[*].storage_permissions))
    }
  ]

  #service_principal_object_id = data.azurerm_client_config.current.object_id
#
  #self_permissions = {
  #  object_id               = local.service_principal_object_id
  #  tenant_id               = data.azurerm_client_config.current.tenant_id
  #  key_permissions         = ["Create", "Delete", "Get", "Backup", "Decrypt", "Encrypt", "Import", "List", "Purge", "Recover", "Restore", "Sign", "Update", "Verify"]
  #  secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  #  certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
  #  storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
  #}
}

data "azuread_group" "adgrp" {
  count        = length(local.azure_ad_group_names)
  display_name = local.azure_ad_group_names[count.index]
}

data "azuread_user" "adusr" {
  count               = length(local.azure_ad_user_principal_names)
  user_principal_name = local.azure_ad_user_principal_names[count.index]
}

data "azuread_service_principal" "adspn" {
  count        = length(local.azure_ad_service_principal_names)
  display_name = local.azure_ad_service_principal_names[count.index]
}

#----------------------------------------------------------
# Resource Group Creation or selection - Default is "true"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = var.tags
}

data "azurerm_client_config" "current" {}

#-------------------------------------------------
# Keyvault Creation - Default is "true"
#-------------------------------------------------
resource "azurerm_key_vault" "main" {
  name                            = lower("${var.key_vault_name}")
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_pricing_tier
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.enable_purge_protection
  tags                            = var.tags

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  dynamic "access_policy" {
    for_each = local.combined_access_policies
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  #dynamic "access_policy" {
  #  for_each = local.service_principal_object_id != "" ? [local.self_permissions] : []
  #  content {
  #    tenant_id               = data.azurerm_client_config.current.tenant_id
  #    object_id               = access_policy.value.object_id
  #    certificate_permissions = access_policy.value.certificate_permissions
  #    key_permissions         = access_policy.value.key_permissions
  #    secret_permissions      = access_policy.value.secret_permissions
  #    storage_permissions     = access_policy.value.storage_permissions
  #  }
  #}

  dynamic "contact" {
    for_each = var.certificate_contacts
    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#---------------------------------------------------------
# Private Link for Keyvault - Default is "false" 
#---------------------------------------------------------
data "azurerm_subnet" "sn" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.network_resource_group
}

resource "azurerm_private_endpoint" "pep1" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.sn.id
  tags                = var.tags
  
  private_dns_zone_group {
    name                 = "keyvault-privatelink-group"
    private_dns_zone_ids = ["/subscriptions/<sub_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
  }
 
  private_service_connection {
    name                           = "keyvault-privatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
