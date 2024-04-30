resource "azurerm_public_ip" "pi" {
  count               = length(var.public_ip)
  name                = var.public_ip[count.index].name
  resource_group_name = var.public_ip[count.index].resource_group_name
  location            = var.public_ip[count.index].location
  allocation_method   = var.public_ip[count.index].allocation_method
  sku                 = var.public_ip[count.index].sku
  domain_name_label   = var.public_ip[count.index].domain_name_label == "" ? null : var.public_ip[count.index].domain_name_label
  tags                = var.public_ip[count.index].tags
}
