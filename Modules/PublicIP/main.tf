resource "azurerm_public_ip" "example" {
  count               = length(var.public_ip)
  name                = var.public_ip[count.index].name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip[count.index].allocation_method
  sku                 = var.public_ip[count.index].sku

  tags = var.tags
}