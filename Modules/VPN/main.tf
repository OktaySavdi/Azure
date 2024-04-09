#----------------------------------------------------------
# Resource Group, VNet, Subnet selection & Random Resources
#----------------------------------------------------------
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = "GatewaySubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

#---------------------------------------------
# Public IP for Virtual Network Gateway
#---------------------------------------------
resource "azurerm_public_ip" "pip_gw" {
  name                = var.azurerm_public_ip
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  tags                = var.tags
}


resource "azurerm_public_ip" "pip_aa" {
  count               = var.enable_active_active ? 1 : 0
  name                = lower("${var.vpn_gateway_name}-${data.azurerm_resource_group.rg.location}-gw-aa-pip")
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  tags                = var.tags
}

#-------------------------------
# Virtual Network Gateway 
#-------------------------------
resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = var.vpn_gateway_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  type                = var.gateway_type
  vpn_type            = var.gateway_type != "ExpressRoute" ? var.vpn_type : null
  sku                 = var.gateway_type != "ExpressRoute" ? var.vpn_gw_sku : var.expressroute_sku
  active_active       = var.vpn_gw_sku != "Basic" ? var.enable_active_active : false
  enable_bgp          = var.vpn_gw_sku != "Basic" ? var.enable_bgp : false
  generation          = var.vpn_gw_generation


  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [true] : []
    content {
      asn = var.bgp_asn_number
      #peering_address = var.bgp_peering_address
      peer_weight = var.bgp_peer_weight
    }
  }

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.snet.id
  }

  dynamic "ip_configuration" {
    for_each = var.enable_active_active ? [true] : []
    content {
      name                          = "vnetGatewayAAConfig"
      public_ip_address_id          = azurerm_public_ip.pip_gw.id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = data.azurerm_subnet.snet.id
    }
  }

  dynamic "vpn_client_configuration" {
    for_each = var.vpn_client_configuration != null ? [var.vpn_client_configuration] : []
    iterator = vpn
    content {
      address_space = [vpn.value.address_space]
      root_certificate {
        name             = "point-to-site-root-certifciate"
        public_cert_data = vpn.value.certificate
      }
      vpn_client_protocols = vpn.value.vpn_client_protocols
    }
  }
  tags = var.tags
}

#---------------------------
# Local Network Gateway
#---------------------------
resource "azurerm_local_network_gateway" "localgw" {
  count               = length(var.local_networks)
  name                = var.local_networks[count.index].local_gw_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  gateway_address     = var.local_networks[count.index].local_gateway_address
  address_space       = var.local_networks[count.index].local_address_space

  dynamic "bgp_settings" {
    for_each = var.local_bgp_settings != null ? [true] : []
    content {
      asn                 = var.local_bgp_settings[count.index].asn_number
      bgp_peering_address = var.local_bgp_settings[count.index].peering_address
      peer_weight         = var.local_bgp_settings[count.index].peer_weight
    }
  }
  tags = var.tags
}

#---------------------------------------
# Virtual Network Gateway Connection
#---------------------------------------
resource "azurerm_virtual_network_gateway_connection" "az-hub-onprem" {
  count                           = var.gateway_connection_type == "ExpressRoute" ? 1 : length(var.local_networks)
  name                            = var.connection_name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  type                            = var.gateway_connection_type
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id        = var.gateway_connection_type != "ExpressRoute" ? azurerm_local_network_gateway.localgw[count.index].id : null
  express_route_circuit_id        = var.gateway_connection_type == "ExpressRoute" ? var.express_route_circuit_id : null
  peer_virtual_network_gateway_id = var.gateway_connection_type == "Vnet2Vnet" ? var.peer_virtual_network_gateway_id : null
  shared_key                      = var.gateway_connection_type != "ExpressRoute" ? var.local_networks[count.index].shared_key : null
  connection_protocol             = var.gateway_connection_type == "IPSec" && var.vpn_gw_sku == ["VpnGw1", "VpnGw2", "VpnGw3", "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ"] ? var.gateway_connection_protocol : null

  dynamic "ipsec_policy" {
    for_each = var.local_networks_ipsec_policy != null ? [true] : []
    content {
      dh_group         = var.dh_group
      ike_encryption   = var.ike_encryption
      ike_integrity    = var.ike_integrity
      ipsec_encryption = var.ipsec_encryption
      ipsec_integrity  = var.ipsec_integrity
      pfs_group        = var.pfs_group
      sa_datasize      = var.sa_datasize
      sa_lifetime      = var.sa_lifetime
    }
  }
  tags = var.tags
}
