output "public_ips" {
  value = [
    for ip in azurerm_public_ip.pi :
    {
      name               = ip.name
      id                 = ip.id
      ip_address         = ip.ip_address
      resource_group_name = ip.resource_group_name
    }
  ]
}
