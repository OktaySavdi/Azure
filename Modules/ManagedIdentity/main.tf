resource "azurerm_user_assigned_identity" "managedIdentity" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "assgin_role" {
  count              = length(var.assignments)
  scope              = var.assignments[count.index].scope
  role_definition_name = var.assignments[count.index].role_definition_name
  principal_id       = azurerm_user_assigned_identity.managedIdentity.principal_id

  depends_on = [azurerm_user_assigned_identity.managedIdentity]
}
