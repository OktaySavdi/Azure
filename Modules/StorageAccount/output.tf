output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storeacc.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storeacc.name
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = azurerm_storage_account.storeacc.primary_location
}

output "storage_account_primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.storeacc.primary_blob_endpoint
}

output "storage_account_private_endpoint_name" {
  description = "The Private endpoint name"
  value       = azurerm_private_endpoint.pe-st.name
}

output "storage_account_private_endpoint_subnet_id" {
  description = "The Private endpoint subnet_id"
  value       = azurerm_private_endpoint.pe-st.subnet_id
}

output "primary_access_key" {
  description = "The Private endpoint primary_access_key"
  value       = azurerm_storage_account.storeacc.primary_access_key
  sensitive   = true
}

output "containers" {
  description = "Map of containers."
  value       = { for c in azurerm_storage_container.container : c.name => c.id }
}

output "file_shares" {
  description = "Map of Storage SMB file shares."
  value       = { for f in azurerm_storage_share.fileshare : f.name => f.id }
}

output "tables" {
  description = "Map of Storage SMB file shares."
  value       = { for t in azurerm_storage_table.tables : t.name => t.id }
}

output "queues" {
  description = "Map of Storage SMB file shares."
  value       = { for q in azurerm_storage_queue.queues : q.name => q.id }
}
