#--------------------------------------------------------------------------------------------------------
# virtual network
#--------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

#--------------------------------------------------------------------------------------------------------
# route table Creation
#--------------------------------------------------------------------------------------------------------

resource "azurerm_route_table" "route_table" {
  for_each                      = var.subnets
  name                          = each.value.rt_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  dynamic "route" {
    for_each = each.value.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }

  tags = var.tags

  depends_on = [azurerm_subnet.snet]
}

#--------------------------------------------------------------------------------------------------------
# Subnets Creation
#--------------------------------------------------------------------------------------------------------

resource "azurerm_subnet" "snet" {
  for_each                                  = var.subnets
  name                                      = each.value.subnet_name
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = each.value.subnet_address_prefix
  service_endpoints                         = lookup(each.value, "service_endpoints", [])
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled
}

#-----------------------------------------------
# Network security group
#-----------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = each.value.nsg_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = each.value.tags

  depends_on = [azurerm_subnet.snet]
}

#-----------------------------------------------
# subnet and network security group association
#-----------------------------------------------

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
  depends_on                = [azurerm_network_security_group.nsg, azurerm_subnet.snet]
}

#-----------------------------------------------
# subnet and route table association
#-----------------------------------------------
resource "azurerm_subnet_route_table_association" "snet_rt_assoc" {
  for_each       = var.subnets
  subnet_id      = azurerm_subnet.snet[each.key].id
  route_table_id = azurerm_route_table.route_table[each.key].id
  depends_on     = [azurerm_route_table.route_table, azurerm_subnet.snet]
}
