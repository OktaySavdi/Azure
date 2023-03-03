output "id" {
  description = "Id of Managed identity."
  value = "${azurerm_user_assigned_identity.managedIdentity.id}"
}

output "client_id" {
  description = "Clinet id of Managed identity."
  value = "${azurerm_user_assigned_identity.managedIdentity.client_id}"
}

output "principal_id" {
  description = "principal id of Managed identity."
  value     = "${azurerm_user_assigned_identity.managedIdentity.principal_id}"
}
