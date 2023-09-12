```
#Resource Group
terraform import module.vnet.azurerm_virtual_network.vnet /subscriptions/<subscription>/resourceGroups/<resource_group_name>
terraform import azurerm_resource_group.rg_name /subscriptions/<subscription>/resourceGroups/<resource_group_name>

#Vnet
terraform import module.vnet.azurerm_virtual_network.vnet /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>

#Subnet
terraform import module.vnet.azurerm_subnet.snet[\"<subnet_name>\"] /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>

#NSG Rules
terraform import module.acr_security-rule5.azurerm_network_security_rule.security_rule[0] /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/networkSecurityGroups/<nsg_name>/securityRules/<nsg_rule_name> (example in-allow-mydomain-net)
terraform import module.acr_security-rule5.azurerm_network_security_rule.security_rule[1] /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/networkSecurityGroups/<nsg_name>/securityRules/<nsg_rule_name> (example out-allow-mydomain-net)

#NSG 
terraform import module.vnet.azurerm_network_security_group.nsg[\"<subnet_name>\"] /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/networkSecurityGroups/<nsg_name>

#NSG association
terraform import module.vnet.azurerm_subnet_network_security_group_association.nsg-assoc[\"<subnet_name>\"] /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>

#Route Table
terraform import module.vnet.azurerm_route_table.route_tables[\"<route_table_name>1\"] /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/routeTables/<route_table_name>

#Route table association
terraform import module.vnet.azurerm_subnet_route_table_association.snet_rt_assoc[\"<subnet_name>\"] /subscriptions/<subscription>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>

#Role assignment
terraform import azurerm_role_assignment.nrgs-roles[\"group1\"] /subscriptions/<subscription>/providers/Microsoft.Authorization/roleAssignments/<Object_ID>

terraform import module.role-assignments-dev.azurerm_role_assignment.role_assigment[0] /subscriptions/<subscription>/resourcegroups/<resource_group_name>/providers/Microsoft.ContainerService/managedClusters/<aks_cluster_name>/providers/Microsoft.Authorization/roleAssignments/<Object_ID>
```
