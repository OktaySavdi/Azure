resource "azurerm_logic_app_workflow" "workflow" {
  count               = length(var.logic_app)
  name                = var.logic_app[count.index].logic_app_name
  location            = var.logic_app[count.index].location
  resource_group_name = var.logic_app[count.index].resource_group_name
  workflow_version    = var.logic_app[count.index].workflow_version
  workflow_schema     = var.logic_app[count.index].workflow_schema
  tags                = var.logic_app[count.index].tags
}
