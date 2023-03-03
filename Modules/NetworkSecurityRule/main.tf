resource "azurerm_network_security_rule" "security_rule" {
  count                                      = length(var.security_rules)
  name                                       = lookup(var.security_rules[count.index], "name")
  priority                                   = lookup(var.security_rules[count.index], "priority")
  direction                                  = lookup(var.security_rules[count.index], "direction")
  access                                     = lookup(var.security_rules[count.index], "access")
  protocol                                   = lookup(var.security_rules[count.index], "protocol", "*")
  source_port_range                          = lookup(var.security_rules[count.index], "source_port_range", null) == null ? null : lookup(var.security_rules[count.index], "source_port_range")
  source_port_ranges                         = lookup(var.security_rules[count.index], "source_port_ranges", null) == null ? null : lookup(var.security_rules[count.index], "source_port_ranges", null)
  destination_port_range                     = lookup(var.security_rules[count.index], "destination_port_range", null) == null ? null : lookup(var.security_rules[count.index], "destination_port_range")
  destination_port_ranges                    = lookup(var.security_rules[count.index], "destination_port_ranges", null) == null ? null : lookup(var.security_rules[count.index], "destination_port_ranges", null)
  source_address_prefix                      = lookup(var.security_rules[count.index], "source_address_prefix", null) == null ? null : lookup(var.security_rules[count.index], "source_address_prefix")
  source_address_prefixes                    = lookup(var.security_rules[count.index], "source_address_prefixes", null) == null ? null : lookup(var.security_rules[count.index], "source_address_prefixes", null)
  destination_address_prefix                 = lookup(var.security_rules[count.index], "destination_address_prefix", null) == null ? null : lookup(var.security_rules[count.index], "destination_address_prefix")
  destination_address_prefixes               = lookup(var.security_rules[count.index], "destination_address_prefixes", null) == null ? null : lookup(var.security_rules[count.index], "destination_address_prefixes", null)
  description                                = lookup(var.security_rules[count.index], "description", "Security rule for ${lookup(var.security_rules[count.index], "name", "default_rule_name")}")
  resource_group_name                        = var.resource_group_name
  network_security_group_name                = var.network_security_group_name
  source_application_security_group_ids      = lookup(var.security_rules[count.index], "source_application_security_group_ids", null)
  destination_application_security_group_ids = lookup(var.security_rules[count.index], "destination_application_security_group_ids", null)
}
