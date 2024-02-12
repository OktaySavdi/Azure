output "node_pool_info" {
  value = {
    for node_name, node_config in azurerm_kubernetes_cluster_node_pool.nodepool :
    node_name => {
      name                     = node_config.name
      mode                     = node_config.mode
      vm_size                  = node_config.vm_size
      os_disk_size_gb          = node_config.os_disk_size_gb
      os_disk_type             = node_config.os_disk_type
      node_count               = node_config.node_count
      min_count                = node_config.min_count
      max_count                = node_config.max_count
      max_pods                 = node_config.max_pods
      priority                 = node_config.priority
      eviction_policy          = node_config.eviction_policy
      vnet_subnet_id           = node_config.vnet_subnet_id
      zones                    = node_config.zones
      enable_auto_scaling      = node_config.enable_auto_scaling
      enable_node_public_ip    = node_config.enable_node_public_ip
      node_public_ip_prefix_id = node_config.node_public_ip_prefix_id
      node_labels              = node_config.node_labels
      node_taints              = node_config.node_taints
      enable_host_encryption   = node_config.enable_host_encryption
      tags                     = node_config.tags
    }
  }
}
