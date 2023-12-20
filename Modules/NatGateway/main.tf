resource "azurerm_public_ip" "publc_ip" {
  name                  = var.public_ip_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  allocation_method     = var.allocation_method
  sku                   = var.public_ip_sku
  tags                  = var.tags
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_public_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.publc_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_nat_gateway_association" {
  count          = length(var.subnets)
  subnet_id      = var.subnets[count.index]
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}
