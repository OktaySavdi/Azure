resource "azurerm_resource_group" "rg" {
  count    = length(var.rg)
  name     = var.rg[count.index].name
  location = var.rg[count.index].location
  tags     = var.rg[count.index].tags  
}
