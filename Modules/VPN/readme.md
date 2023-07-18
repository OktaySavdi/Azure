# terraform-azurerm-vpn
Virtual Network Gateway terraform module
Terraform module to create a Virtual Network Gateway to send encrypted traffic between an Azure virtual network and an on-premises location over the public Internet. Supports both VPN and ExpressRoute gateway types. VPN configuration supports ExpressRoute (private connection), Site-to-Site and Multi-Site (IPsec/IKE VPN tunnel). Optional active-active mode and point-to-site supported as well.

Creating a virtual network gateway can take up to 45 minutes to complete. When you create a virtual network gateway, gateway VMs are deployed to the gateway subnet and configured with the settings that you specify
Types of resources are supported:

Point-to-Site
Site-to-Site
ExpressRoute

## Usage in Terraform 0.13

```hcl
#----------------------------------------------------------
# Create Vnet
#----------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers

  subnet {
    name           = var.subnet_name
    address_prefix = var.subnet_address_prefix
  }
  tags = var.tags
}

module "vpn-gateway" {
  source = "git::https://mygitlab.com/modules.git//VPN"

  # Resource Group, location, VNet and Subnet details
  # IPSec Site-to-Site connection configuration requirements
  location                    = var.location
  resource_group_name         = var.resource_group_name
  virtual_network_name        = var.vnet_name
  subnet_name                 = var.subnet_name
  vpn_gateway_name            = "az-vpn-test-01"
  azurerm_public_ip           = "az-pi-test-01"
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"
  gateway_type                = "Vpn"
  vpn_gw_sku                  = "VpnGw1"
  vpn_type                    = "RouteBased"
  vpn_gw_generation           = "Generation1"
  enable_active_active        = "false"
  enable_bgp                  = "false"
  local_networks_ipsec_policy = "true"

  # Virtual Network Gateway Connection
  dh_group         = "DHGroup14"
  ike_encryption   = "AES256"
  ike_integrity    = "SHA256"
  ipsec_encryption = "AES256"
  ipsec_integrity  = "SHA256"
  pfs_group        = "None"
  sa_datasize      = "102400000"
  sa_lifetime      = "3600"

  # local network gateway connection
  local_networks = [
    {
      local_gw_name         = "az-lg-test-01"
      local_gateway_address = "120.12.12.12"
      local_address_space   = ["10.0.0.0.0/16", "10.10.0.0/15", "10.20.0.0/16"]
      shared_key            = "password"
    },
  ]

  # Adding TAG's to your Azure resources (Required)
  tags = var.tags

  depends_on = [ azurerm_virtual_network.vnet ]
}
```
**variables**
```hcl
variable "resource_group_name" {
  default = "az-rg-test-01"
}

variable "location" {
  default = "westeurope"
}

variable "vnet_name" {
  default = "az-vnet-test-01"
}

variable "vnet_address_space" {
  default = ["10.10.0.0/22"]
}

variable "subnet_address_prefix" {
  default = "10.20.0.0/24"
}

variable "dns_servers" {
  default = ["10.10.10.10"]
}

variable "subnet_name" {
  default = "GatewaySubnet"
}

variable "tags" {
  type = map(string)
  default = {
    DataClassification = "internal"
    Owner              = "hce"
    Environment        = "test"
  }
}


```
**provider**
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.65.0"
    }
  }
 #  backend "azurerm" {
 #    resource_group_name  = "<your rg>" #change
 #    storage_account_name = "<your sa>" #change
 #    container_name       = "<your cn>" #change
 #    key                  = "/<your directoy>" #change
 #    subscription_id      = "<your storage account subscription>" #change
 #  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  subscription_id = "xxxxxxx-xxxxxxx-xxxxxxxx-xxxxxx"
  tenant_id       = "xxxxxxx-xxxxxxx-xxxxxxxx-xxxxxx"
  features {}
}
```
## Requirements

Name | Version
-----|--------
terraform | >= 0.13
azurerm | = 3.65.0

## Providers

| Name | Version |
|------|---------|
azurerm | = 3.65.0



## `local_networks_ipsec_policy` Virtual Network Gateway Connection IPSec Policy  

IPsec and IKE protocol standard supports a wide range of cryptographic algorithms in various combinations. If you do not request a specific combination of cryptographic algorithms and parameters, Azure VPN gateways use a set of default proposals. The default policy sets chosen to maximize interoperability with a wide range of third-party VPN devices in default configurations. As a result, the policies and the number of proposals cannot cover all possible combinations of available cryptographic algorithms and key strengths.

Following parameters can help configure Azure VPN gateways to use a custom IPsec/IKE policy with specific cryptographic algorithms and key strengths, rather than the Azure default policy sets.

Name | Description
---- | -----------
`dh_group`|The DH group used in IKE phase 1 for initial SA. Valid options are `DHGroup1`, `DHGroup14`, `DHGroup2`, `DHGroup2048`, `DHGroup24`, `ECP256`, `ECP384`, or `None`
`ike_encryption`|The IKE encryption algorithm. Valid options are `AES128`, `AES192`, `AES256`, `DES`, or `DES3`
`ike_integrity`|The IKE integrity algorithm. Valid options are `MD5`, `SHA1`, `SHA256`, or `SHA384`
`ipsec_encryption`|The IPSec encryption algorithm. Valid options are `AES128`, `AES192`, `AES256`, `DES`, `DES3`, `GCMAES128`, `GCMAES192`, `GCMAES256`, or `None`
`ipsec_integrity`|The IPSec integrity algorithm. Valid options are `GCMAES128`, `GCMAES192`, `GCMAES256`, `MD5`, `SHA1`, or `SHA256`
`pfs_group`|The DH group used in IKE phase 2 for new child SA. Valid options are `ECP256`, `ECP384`, `PFS1`, `PFS2`, `PFS2048`, `PFS24`, or `None`
`sa_datasize`|The IPSec SA payload size in KB. Must be at least `1024` KB. Defaults to `102400000` KB.
`sa_lifetime`|The IPSec SA lifetime in seconds. Must be at least `300` seconds. Defaults to `27000` seconds

## `local_networks` Local Virtual Network Connections

A local network gateway represents the hardware or software VPN device in your local network. Use this with a connection to set up a site-to-site VPN connection between an Azure virtual network and your local network. Following parameters can help configure Azure local virtual network gateways with your on-premise network.

Name | Description
---- | -----------
`local_gw_name`|The name of the local network gateway
`local_gateway_address`|The IP address of the gateway to which to connect
`local_address_space`|The list of string CIDRs representing the address spaces the gateway exposes
`shared_key`| The shared `IPSec` key. A key could be provided if a `Site-to-Site`, `VNet-to-VNet` or `ExpressRoute` connection is created

## `vpn_client_configuration` IPSec point-to-site connections

A Point-to-Site (P2S) VPN gateway connection lets you create a secure connection to your virtual network from an individual client computer. A P2S connection is established by starting it from the client computer. This solution is useful for telecommuters who want to connect to Azure VNets from a remote location, such as from home or a conference. P2S VPN is also a useful solution to use instead of S2S VPN when you have only a few clients that need to connect to a VNet. Following parameters are required to configure P2S connection with client computer.

Name | Description
---- | -----------
`address_space`|The address space out of which IP addresses for VPN clients will be taken. You can provide more than one address space, e.g. in CIDR notation
`certifciate_path`|The public certificate of the root certificate authority. The certificate must be provided in Base-64 encoded X.509 format (PEM). In particular, this argument must not include the -----BEGIN CERTIFICATE----- or -----END CERTIFICATE----- markers
`vpn_client_protocols`| List of the protocols supported by the VPN client. The supported values are `SSTP`, `IkeV2` and `OpenVPN`

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`resource_group_name` | The name of the resource group in which resources are created | string | `""`
`location`|The location of the resource group in which resources are created|string | `""`
`virtual_network_name`|The name of the virtual network|string |`""`
`subnet_name`|The name of the subnet to use in VM scale set|string |`""`
`vpn_gateway_name`|The name of the Virtual Network Gateway|string |`""`
public_ip_allocation_method|Defines the allocation method for this IP address. Possible values are `Static` or `Dynamic`|string| `Dynamic`
`public_ip_sku`|The SKU of the Public IP. Accepted values are `Basic` and `Standard`|string|`Basic`
`gateway_type`|The type of the Virtual Network Gateway. Valid options are `Vpn` or `ExpressRoute`|string|`Vpn`
`vpn_type`|The routing type of the Virtual Network Gateway. Valid options are `RouteBased` or `PolicyBased`|string|`RouteBased`
`vpn_gw_sku`|Configuration of the size and capacity of the virtual network gateway. Valid options are Basic, `VpnGw1`, `VpnGw2`, `VpnGw3`, `VpnGw4`,`VpnGw5`, `VpnGw1AZ`, `VpnGw2AZ`, `VpnGw3AZ`,`VpnGw4AZ` and `VpnGw5AZ` and depend on the `gateway_type`, `vpn_type` and generation arguments|string|`VpnGw1`
`expressroute_sku`|Configuration of the size and capacity of the virtual network gateway for `ExpressRoute` type. Valid options are `Standard`, `HighPerformance`, `UltraPerformance`, `ErGw1AZ`, `ErGw2AZ`, `ErGw3AZ` and depend on the type, `vpn_type` and `generation` arguments|string|`Standard`
`vpn_gw_generation`|The Generation of the Virtual Network gateway. Possible values include `Generation1`, `Generation2` or `None`|string|`Generation1`
`enable_active_active`|If `true`, an `active-active` Virtual Network Gateway will be created. An `active-active` gateway requires a `HighPerformance` or an `UltraPerformance` sku. If `false`, an active-standby gateway will be created|string|`false`
`enable_bgp`|If `true`, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway|string|`false`
`bgp_asn_number`|The Autonomous System Number (ASN) to use as part of the BGP|string|`65515`
`bgp_peering_address`|The BGP peer IP address of the virtual network gateway. This address is needed to configure the created gateway as a BGP Peer on the on-premises VPN devices. The IP address must be part of the subnet of the Virtual Network Gateway|string|`""`
`bgp_peer_weight`|The weight added to routes which have been learned through BGP peering. Valid values can be between `0` and `100`|string|`0`
`vpn_client_configuration`|Virtual Network Gateway client configuration to accept IPSec point-to-site connections|string|`null`
`local_networks`|List of local virtual network connections to connect to gateway|string|`[]`
`local_bgp_settings`|Local Network Gateway's BGP speaker settings|string|`null`
`gateway_connection_type`|The type of connection. Valid options are `IPsec` (Site-to-Site), `ExpressRoute` (ExpressRoute), and `Vnet2Vnet` (VNet-to-VNet)|string|`IPsec`
`express_route_circuit_id`|The ID of the Express Route Circuit when creating an ExpressRoute connection|string|`""`
`peer_virtual_network_gateway_id`|The ID of the peer virtual network gateway when creating a VNet-to-VNet connection|string|`null`
`gateway_connection_protocol`|The IKE protocol version to use. Possible values are `IKEv1` and `IKEv2`|string|`IKEv2`
`local_networks_ipsec_policy`|IPSec policy for local networks. Only a single policy can be defined for a connection|string|`null`
`Tags`|A map of tags to add to all resources|map|`{}`
