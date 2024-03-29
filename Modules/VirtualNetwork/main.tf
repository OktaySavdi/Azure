data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

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

resource "azurerm_route_table" "route_tables" {
  for_each                      = var.route_tables
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

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value.delegationname
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

#-----------------------------------------------
# Network security group
#-----------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsgs
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = each.value.tags
}

#-----------------------------------------------
# subnet and network security group association
#-----------------------------------------------

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = { for subnet, config in var.subnets : subnet => config if config.nsg_name != "" }
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = "${data.azurerm_resource_group.rg.id}/providers/Microsoft.Network/networkSecurityGroups/${each.value.nsg_name}"

   depends_on = [azurerm_network_security_group.nsg]
}

#-----------------------------------------------
# subnet and route table association
#-----------------------------------------------
resource "azurerm_subnet_route_table_association" "snet_rt_assoc" {

  for_each       = { for subnet, config in var.subnets : subnet => config if config.rt_name != "" }
  subnet_id      = azurerm_subnet.snet[each.key].id
  route_table_id = "${data.azurerm_resource_group.rg.id}/providers/Microsoft.Network/routeTables/${each.value.rt_name}"

  depends_on = [azurerm_route_table.route_tables]
}

#-----------------------------------------------
# disk access
#-----------------------------------------------
resource "azurerm_disk_access" "disk_access" {
  name                = var.disk_access_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

#-----------------------------------------------
# private endpoint for each subnet
#-----------------------------------------------
resource "azurerm_private_endpoint" "private_endpoint" {
  for_each            = { for subnet, config in var.subnets : subnet => config if config.private_endpoint_name != "" }
  name                = each.value.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.snet[each.key].id

  private_service_connection {
    name                           = "${each.value.private_endpoint_name}-connection"
    private_connection_resource_id = azurerm_disk_access.disk_access.id
    is_manual_connection           = false
    subresource_names              = ["disks"]
  }

  tags       = each.value.tags
  depends_on = [azurerm_disk_access.disk_access]
}
