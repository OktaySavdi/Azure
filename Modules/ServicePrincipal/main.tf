resource "azuread_application" "application" {
  display_name = var.service_principal_name
  owners       = var.service_principal_owner
}

resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.application.application_id
  owners         = var.service_principal_owner
}

resource "azuread_application_password" "application_password" {
  application_object_id = azuread_application.application.object_id
  end_date_relative     = "8760h"
}

resource "azurerm_role_assignment" "role_assigment" {
  count                = length(var.assignments)
  scope                = var.assignments[count.index].scope
  role_definition_name = var.assignments[count.index].role_definition_name
  principal_id         = azuread_service_principal.service_principal.id
}