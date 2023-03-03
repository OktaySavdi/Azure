resource "azurerm_role_assignment" "role_assigment" {
  count                = length(var.assignments)
  scope                = var.assignments[count.index].scope
  role_definition_name = var.assignments[count.index].role_definition_name
  principal_id         = var.assignments[count.index].principal_id
}