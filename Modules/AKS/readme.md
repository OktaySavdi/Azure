# Terraform Azure AKS Module

This Terraform module deploys a Kubernetes cluster on Azure using AKS (Azure Kubernetes Service)

## Usage in Terraform

**variables.tf**
```hcl
variable "tags" {
  type = map(string)
  default = {
    "DataClassification" = "internal"
    "Owner"              = "<team_Name>"
    "Platform"           = "<platform_name>"
    "Environment"        = "nonprod"
  }
}

variable "environment" {
  description = "Environment name. Possible values are stg and prod"
  type        = string
  default     = "stg-01"
}

variable "project" {
  description = "Project name. Please specify your project name"
  type        = string
  default     = "hce-aks"
}

variable "subscription" {
  description = "Subscription info"
  type        = string
  default     = "<subscription_ID>"
}

variable "kubernetes_version" {
  description = "kubernetes version"
  type        = string
  default     = "1.28.0"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "germanywestcentral"
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "az-rg-aks-dev-01"
}

variable "network_plugin" {
  description = "Network plugin to use for networking - Possible values kubenet and azure"
  type        = string
  default     = "azure"
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium"
  type        = string
  default     = "Free"
}

variable "rbac_aad_admin_group_object_ids" {
  description = "Object ID of groups with admin access"
  type        = list(any)
  default     = ["<group_id>", "<user_id>", "111111-1111-1111-1111-111111"]
}

variable "net_profile_outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting"
  type        = string
  default     = "userDefinedRouting"
}

variable "azure_subnet_id" {
  description = "Azure network configuration, subnet ID"
  type        = string
  default     = "/subscriptions/<subscription_ID>/resourceGroups/<resorcegroup_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
}

variable "private_dns_zone_id" {
  description = "private dns zone name"
  type        = string
  default     = "privatelink.germanywestcentral.azmk8s.io"
}

variable "identity_type" {
  type        = string
  description = "The type of identity used for the managed cluster. Conflicts with `client_id` and `client_secret`. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, an `identity_ids` must be set as well."
  default     = "UserAssigned"
}

variable "identity_ids" {
  type        = string
  description = "pecifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster."
  default     = "az-mi-hce-myproject-dev-01"
}

variable "add_on" {
  type = map(string)
  default = {
    "role_based_access_control_enabled"   = true  #Enable Role Based Access Control.
    "rbac_aad_managed"                    = true  #Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration.
    "open_service_mesh_enabled"           = false #Enable Service Mesh.  
    "private_cluster_enabled"             = true  #If true cluster API server will be exposed only on internal IP address and available only in cluster vnet.
    "azure_policy_enabled"                = true  #Enable Azure Policy.
    "enable_auto_scaling"                 = false #Enable node pool autoscaling.
    "enable_host_encryption"              = false #Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli
    "local_account_disabled"              = false #If true local accounts will be disabled. See the documentation for more information.
    "log_analytics_workspace_enabled"     = false
  }
}

variable "default_node_pool" {
  type = map(string)
  default = {
    name                     = "default"
    vm_size                  = "Standard_D2_v5"
    os_sku                   = "Ubuntu"
    os_disk_size_gb          = 128
    node_count               = 1
    min_count                = null
    max_count                = null
    max_pods                 = 250
  }
}

variable "node_pools" {
  description = "For each nodepool, create an object that contain fields"
  default = {
    node1 = {
      name                     = "ubuntu01"
      vm_size                  = "Standard_D2_v5"
      orchestrator_version     = "1.27.9"
      enable_auto_scaling      = false
      os_sku                   = "AzureLinux"
      mode                     = "User"
      os_disk_size_gb          = 128
      os_disk_type             = "Managed"
      node_count               = 1
      min_count                = 0
      max_count                = 0
      max_pods                 = 175
      enable_node_public_ip    = false
      enable_host_encryption   = false
      vnet_subnet_id           = "/subscriptions/<subscription_ID>/resourceGroups/<resorcegroup_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
      tags = {
        "DataClassification" = "internal"
        "Owner"              = "<team_Name>"
        "Platform"           = "<platform_name>"
         "Environment"        = "nonprod"
      }
    },
    #node2 = {
    #  name                     = "azurelinux02"
    #  vm_size                  = "Standard_D2_v5"
    #  orchestrator_version     = "1.27.7"
    #  enable_auto_scaling      = true
    #  os_sku                   = "Ubuntu"
    #  mode                     = "System"
    #  os_disk_size_gb          = 128
    #  os_disk_type             = "Managed"
    #  min_count                = 1
    #  max_count                = 2
    #  enable_node_public_ip    = false
    #  enable_host_encryption   = false
    #  max_pods                 = 250
    #  vnet_subnet_id           = "/subscriptions/<subscription_ID>/resourceGroups/<resorcegroup_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
    #  tags = {
    #   "DataClassification" = "internal"
    #   "Owner"              = "<team_Name>"
    #   "Platform"           = "<platform_name>"
    #    "Environment"        = "nonprod"
    # }
    #}
  }
}
```
**main.tf**
```hcl
### Data sources ####
data "azurerm_user_assigned_identity" "manage_identity" {
  provider            = azurerm.subscription
  name                = var.identity_ids
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "kv" {
  provider            = azurerm.keyvault-sub
  name                = "<keyvault_name>"
  resource_group_name = "<resourcegroup_name>"
}

// Private DNS Zone
data "azurerm_private_dns_zone" "full_zone" {
  provider = azurerm.private-dns
  name     = var.private_dns_zone_id
}


// Deploys a Kubernetes cluster on AKS with monitoring support through Azure Log Analytics
module "aks" {
  // provider                      = azurerm.prod-sub
  source = "git::https://ato-hce-git1.gtoffice.lan/hce-public/modules.git//AKS?ref=v3.97.1"
  providers = {
    azurerm = azurerm.subscription
  }
  location                          = var.location
  resource_group_name               = var.resource_group_name
  kubernetes_version                = var.kubernetes_version
  orchestrator_version              = var.kubernetes_version
  prefix                            = "az-dns-${var.project}-${var.environment}"
  cluster_name                      = "az-aks-${var.project}-${var.environment}"
  network_plugin                    = var.network_plugin
  identity_type                     = var.identity_type
  identity_ids                      = [data.azurerm_user_assigned_identity.manage_identity.id]
  vnet_subnet_id                    = var.azure_subnet_id
  private_dns_zone_id               = data.azurerm_private_dns_zone.full_zone.id
  sku_tier                          = var.sku_tier
  net_profile_outbound_type         = var.net_profile_outbound_type
  role_based_access_control_enabled = var.add_on.role_based_access_control_enabled
  rbac_aad_managed                  = var.add_on.rbac_aad_managed
  rbac_aad_admin_group_object_ids   = var.rbac_aad_admin_group_object_ids
  open_service_mesh_enabled         = var.add_on.open_service_mesh_enabled
  private_cluster_enabled           = var.add_on.private_cluster_enabled
  local_account_disabled            = var.add_on.local_account_disabled
  log_analytics_workspace_enabled   = var.add_on.log_analytics_workspace_enabled
  azure_policy_enabled              = var.add_on.azure_policy_enabled
  enable_auto_scaling               = var.add_on.enable_auto_scaling
  enable_host_encryption            = var.add_on.enable_host_encryption
  node_pools                        = var.node_pools
  agents_pool_name                  = var.default_node_pool.name
  agents_size                       = var.default_node_pool.vm_size
  os_sku                            = var.default_node_pool.os_sku
  os_disk_size_gb                   = var.default_node_pool.os_disk_size_gb
  agents_count                      = var.default_node_pool.node_count
  agents_min_count                  = var.default_node_pool.min_count
  agents_max_count                  = var.default_node_pool.max_count
  agents_max_pods                   = var.default_node_pool.max_pods
  tags = var.tags
}
```
**providers.tf**
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.97.1"
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
  alias                  = "keyvault-sub"
  subscription_id        = "<subscription_ID>"
  tenant_id              = "<tenant_ID>"
  features {}
}
 
provider "azurerm" {
  alias                  = "subscription"
  subscription_id        = var.subscription
  tenant_id              = "<tenant_ID>"
  features {}
}

provider "azurerm" {
  alias                  = "private-dns"
  subscription_id        = "<subscription_ID>"
  tenant_id              = "<tenant_ID>"
  features {}
}
```
**Outputs.tf**
```hcl
output "admin_client_certificate" {
  sensitive = true
  value     = module.aks.admin_client_certificate
}

output "admin_client_key" {
  sensitive = true
  value     = module.aks.admin_client_key
}

output "admin_cluster_ca_certificate" {
  sensitive = true
  value     = module.aks.admin_client_certificate
}

output "admin_host" {
  sensitive = true
  value     = module.aks.admin_host
}

output "admin_password" {
  sensitive = true
  value     = module.aks.admin_password
}

output "admin_username" {
  sensitive = true
  value     = module.aks.admin_username
}

output "aks_id" {
  value = module.aks.aks_id
}

output "client_certificate" {
  sensitive = true
  value     = module.aks.client_certificate
}

output "client_key" {
  sensitive = true
  value     = module.aks.client_key
}

output "cluster_ca_certificate" {
  sensitive = true
  value     = module.aks.client_certificate
}

output "cluster_portal_fqdn" {
  value = module.aks.cluster_portal_fqdn
}

output "cluster_private_fqdn" {
  value = module.aks.cluster_private_fqdn
}

output "host" {
  sensitive = true
  value     = module.aks.host
}

output "kube_raw" {
  sensitive = true
  value     = module.aks.kube_config_raw
}

output "password" {
  sensitive = true
  value     = module.aks.password
}

output "username" {
  sensitive = true
  value     = module.aks.username
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.97.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.97.1 |


## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.nodepool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_log_analytics_solution.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [null_resource.http_proxy_config_no_proxy_keeper](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.kubernetes_cluster_name_keeper](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.kubernetes_version_keeper](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aci_connector_linux_enabled"></a> [aci\_connector\_linux\_enabled](#input\_aci\_connector\_linux\_enabled) | Enable Virtual Node pool | `bool` | `false` | no |
| <a name="input_aci_connector_linux_subnet_name"></a> [aci\_connector\_linux\_subnet\_name](#input\_aci\_connector\_linux\_subnet\_name) | (Optional) aci\_connector\_linux subnet name | `string` | `null` | no |       
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The username of the local administrator to be created on the Kubernetes cluster. Set this variable to `null` to turn off the cluster's `linux_profile`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_agents_availability_zones"></a> [agents\_availability\_zones](#input\_agents\_availability\_zones) | (Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created. | `list(string)` | `null` | no |
| <a name="input_agents_count"></a> [agents\_count](#input\_agents\_count) | The number of Agents that should exist in the Agent Pool. Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes. | `number` | `2` | no |
| <a name="input_agents_labels"></a> [agents\_labels](#input\_agents\_labels) | (Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created. | `map(string)` | `{}` | no |
| <a name="input_agents_max_count"></a> [agents\_max\_count](#input\_agents\_max\_count) | Maximum number of nodes in a pool | `number` | `null` | no |
| <a name="input_agents_max_pods"></a> [agents\_max\_pods](#input\_agents\_max\_pods) | (Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. | `number` | `null` | no |
| <a name="input_agents_min_count"></a> [agents\_min\_count](#input\_agents\_min\_count) | Minimum number of nodes in a pool | `number` | `null` | no |
| <a name="input_agents_pool_max_surge"></a> [agents\_pool\_max\_surge](#input\_agents\_pool\_max\_surge) | The maximum number or percentage of nodes which will be added to the Default Node Pool size during an upgrade. | `string` | `null` | no |
| <a name="input_agents_pool_name"></a> [agents\_pool\_name](#input\_agents\_pool\_name) | The default Azure AKS agentpool (nodepool) name. | `string` | `"nodepool"` | no |
| <a name="input_agents_proximity_placement_group_id"></a> [agents\_proximity\_placement\_group\_id](#input\_agents\_proximity\_placement\_group\_id) | (Optional) The ID of the Proximity Placement Group of the default Azure AKS agentpool (nodepool). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_agents_size"></a> [agents\_size](#input\_agents\_size) | The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_agents_tags"></a> [agents\_tags](#input\_agents\_tags) | (Optional) A mapping of tags to assign to the Node Pool. | `map(string)` | `{}` | no |
| <a name="input_agents_taints"></a> [agents\_taints](#input\_agents\_taints) | (Optional) A list of the taints added to new nodes during node pool create and scale. Changing this forces a new resource to be created. | `list(string)` | `null` | no |
| <a name="input_agents_type"></a> [agents\_type](#input\_agents\_type) | (Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets. | `string` | `"VirtualMachineScaleSets"` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | (Optional) The IP ranges to allow for incoming traffic to the server nodes. | `set(string)` | `null` | no |
| <a name="input_api_server_subnet_id"></a> [api\_server\_subnet\_id](#input\_api\_server\_subnet\_id) | (Optional) The ID of the Subnet where the API server endpoint is delegated to. | `string` | `null` | no |        
| <a name="input_attached_acr_id_map"></a> [attached\_acr\_id\_map](#input\_attached\_acr\_id\_map) | Azure Container Registry ids that need an authentication mechanism with Azure Kubernetes Service (AKS). Map key must be static string as acr's name, the value is acr's resource id. Changing this forces some new resources to be created. | `map(string)` | `{}` | no |
| <a name="input_auto_scaler_profile_balance_similar_node_groups"></a> [auto\_scaler\_profile\_balance\_similar\_node\_groups](#input\_auto\_scaler\_profile\_balance\_similar\_node\_groups) | Detect similar node groups and balance the number of nodes between them. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_auto_scaler_profile_empty_bulk_delete_max"></a> [auto\_scaler\_profile\_empty\_bulk\_delete\_max](#input\_auto\_scaler\_profile\_empty\_bulk\_delete\_max) | Maximum number of empty nodes that can be deleted at the same time. Defaults to `10`. | `number` | `10` | no |
| <a name="input_auto_scaler_profile_enabled"></a> [auto\_scaler\_profile\_enabled](#input\_auto\_scaler\_profile\_enabled) | Enable configuring the auto scaler profile | `bool` | `false` | no |
| <a name="input_auto_scaler_profile_expander"></a> [auto\_scaler\_profile\_expander](#input\_auto\_scaler\_profile\_expander) | Expander to use. Possible values are `least-waste`, `priority`, `most-pods` and `random`. Defaults to `random`. | `string` | `"random"` | no |
| <a name="input_auto_scaler_profile_max_graceful_termination_sec"></a> [auto\_scaler\_profile\_max\_graceful\_termination\_sec](#input\_auto\_scaler\_profile\_max\_graceful\_termination\_sec) | Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to `600`. | `string` | `"600"` | no |
| <a name="input_auto_scaler_profile_max_node_provisioning_time"></a> [auto\_scaler\_profile\_max\_node\_provisioning\_time](#input\_auto\_scaler\_profile\_max\_node\_provisioning\_time) | Maximum time the autoscaler waits for a node to be provisioned. Defaults to `15m`. | `string` | `"15m"` | no |
| <a name="input_auto_scaler_profile_max_unready_nodes"></a> [auto\_scaler\_profile\_max\_unready\_nodes](#input\_auto\_scaler\_profile\_max\_unready\_nodes) | Maximum Number of allowed unready nodes. Defaults to `3`. | `number` | `3` | no |
| <a name="input_auto_scaler_profile_max_unready_percentage"></a> [auto\_scaler\_profile\_max\_unready\_percentage](#input\_auto\_scaler\_profile\_max\_unready\_percentage) | Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to `45`. | `number` | `45` | no |
| <a name="input_auto_scaler_profile_new_pod_scale_up_delay"></a> [auto\_scaler\_profile\_new\_pod\_scale\_up\_delay](#input\_auto\_scaler\_profile\_new\_pod\_scale\_up\_delay) | For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to `10s`. | `string` | `"10s"` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_add"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_add](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_add) | How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to `10m`. | `string` | `"10m"` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_delete"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_delete](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_delete) | How long after node deletion that scale down evaluation resumes. Defaults to the value used for `scan_interval`. | `string` | `null` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_failure"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_failure](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_failure) | How long after scale down failure that scale down evaluation resumes. Defaults to `3m`. | `string` | `"3m"` | no |
| <a name="input_auto_scaler_profile_scale_down_unneeded"></a> [auto\_scaler\_profile\_scale\_down\_unneeded](#input\_auto\_scaler\_profile\_scale\_down\_unneeded) | How long a node should be unneeded before it is eligible for scale down. Defaults to `10m`. | `string` | `"10m"` | no |
| <a name="input_auto_scaler_profile_scale_down_unready"></a> [auto\_scaler\_profile\_scale\_down\_unready](#input\_auto\_scaler\_profile\_scale\_down\_unready) | How long an unready node should be unneeded before it is eligible for scale down. Defaults to `20m`. | `string` | `"20m"` | no |
| <a name="input_auto_scaler_profile_scale_down_utilization_threshold"></a> [auto\_scaler\_profile\_scale\_down\_utilization\_threshold](#input\_auto\_scaler\_profile\_scale\_down\_utilization\_threshold) | Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to `0.5`. | `string` | `"0.5"` | no |
| <a name="input_auto_scaler_profile_scan_interval"></a> [auto\_scaler\_profile\_scan\_interval](#input\_auto\_scaler\_profile\_scan\_interval) | How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to `10s`. | `string` | `"10s"` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_local_storage"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage) | If `true` cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_system_pods"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods) | If `true` cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to `true`. | `bool` | `true` | no |
| <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade) | (Optional) The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster) for more information | `string` | `null` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Enable Azure Policy Addon. | `bool` | `false` | no |
| <a name="input_brown_field_application_gateway_for_ingress"></a> [brown\_field\_application\_gateway\_for\_ingress](#input\_brown\_field\_application\_gateway\_for\_ingress) | [Definition of `brown_field`](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing)<br>* `id` - (Required) The ID of the Application Gateway that be used as cluster ingress.<br>* `subnet_id` - (Required) The ID of the Subnet which the Application Gateway is connected to. Must be set when `create_role_assignments` is `true`. | <pre>object({<br>    id        = string<br>    subnet_id = string<br>  })</pre> | `null` | no |  
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | (Optional) The Client ID (appId) for the Service Principal used for the AKS deployment | `string` | `""` | no |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | (Optional) The Client Secret (password) for the Service Principal used for the AKS deployment | `string` | `""` | no |
| <a name="input_cluster_log_analytics_workspace_name"></a> [cluster\_log\_analytics\_workspace\_name](#input\_cluster\_log\_analytics\_workspace\_name) | (Optional) The name of the Analytics workspace | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Optional) The name for the AKS resources created in the specified Azure Resource Group. This variable overwrites the 'prefix' var (The 'prefix' var will still be applied to the dns\_prefix if it is set) | `string` | `null` | no |
| <a name="input_cluster_name_random_suffix"></a> [cluster\_name\_random\_suffix](#input\_cluster\_name\_random\_suffix) | Whether to add a random suffix on Aks cluster's name or not. `azurerm_kubernetes_cluster` resource defined in this module is `create_before_destroy = true` implicity now(described [here](https://github.com/Azure/terraform-azurerm-aks/issues/389)), without this random suffix we'll not be able to recreate this cluster directly due to the naming conflict. | `bool` | `false` | no |
| <a name="input_confidential_computing"></a> [confidential\_computing](#input\_confidential\_computing) | (Optional) Enable Confidential Computing. | <pre>object({<br>    sgx_quote_helper_enabled = bool<br>  })</pre> | `null` | no |
| <a name="input_create_role_assignment_network_contributor"></a> [create\_role\_assignment\_network\_contributor](#input\_create\_role\_assignment\_network\_contributor) | (Deprecated) Create a role assignment for the AKS Service Principal to be a Network Contributor on the subnets used for the AKS Cluster | `bool` | `false` | no |
| <a name="input_create_role_assignments_for_application_gateway"></a> [create\_role\_assignments\_for\_application\_gateway](#input\_create\_role\_assignments\_for\_application\_gateway) | (Optional) Whether to create the corresponding role assignments for application gateway or not. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_default_node_pool_fips_enabled"></a> [default\_node\_pool\_fips\_enabled](#input\_default\_node\_pool\_fips\_enabled) | (Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | (Optional) The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. More information [can be found in the documentation](https://docs.microsoft.com/azure/aks/azure-disk-customer-managed-keys). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_ebpf_data_plane"></a> [ebpf\_data\_plane](#input\_ebpf\_data\_plane) | (Optional) Specifies the eBPF data plane used for building the Kubernetes network. Possible value is `cilium`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable node pool autoscaling | `bool` | `false` | no |
| <a name="input_enable_host_encryption"></a> [enable\_host\_encryption](#input\_enable\_host\_encryption) | Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli | `bool` | `false` | no |
| <a name="input_enable_node_public_ip"></a> [enable\_node\_public\_ip](#input\_enable\_node\_public\_ip) | (Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false. | `bool` | `false` | no |
| <a name="input_green_field_application_gateway_for_ingress"></a> [green\_field\_application\_gateway\_for\_ingress](#input\_green\_field\_application\_gateway\_for\_ingress) | [Definition of `green_field`](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new)<br>* `name` - (Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.<br>* `subnet_cidr` - (Optional) The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.<br>* `subnet_id` - (Optional) The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. | <pre>object({<br>    name        = optional(string)<br>    subnet_cidr = optional(string)<br>    subnet_id   = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_http_proxy_config"></a> [http\_proxy\_config](#input\_http\_proxy\_config) | optional(object({<br>    http\_proxy  = (Optional) The proxy address to be used when communicating over HTTP.<br>    https\_proxy = (Optional) The proxy address to be used when communicating over HTTPS.<br>    no\_proxy    = (Optional) The list of domains that will not use the proxy for communication. Note: If you specify the `default_node_pool.0.vnet_subnet_id`, be sure to include the Subnet CIDR in the `no_proxy` list. Note: You may wish to use Terraform's `ignore_changes` functionality to ignore the changes to this field.<br>    trusted\_ca  = (Optional) The base64 encoded alternative CA certificate content in PEM format.<br>}))<br>Once you have set only one of `http_proxy` and `https_proxy`, this config would be used for both `http_proxy` and `https_proxy` to avoid a configuration drift. | <pre>object({<br>    http_proxy  = optional(string)<br>    https_proxy = optional(string)<br>    no_proxy    = optional(list(string))<br>    trusted_ca  = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster. | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | (Optional) The type of identity used for the managed cluster. Conflicts with `client_id` and `client_secret`. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, an `identity_ids` must be set as well. | `string` | `"SystemAssigned"` | no |
| <a name="input_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#input\_image\_cleaner\_enabled) | (Optional) Specifies whether Image Cleaner is enabled. | `bool` | `false` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | (Optional) Specifies the interval in hours when images should be cleaned up. Defaults to `48`. | `number` | `48` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | (Optional) Whether to use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster. For more details: https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver | `bool` | `false` | no |
| <a name="input_kms_enabled"></a> [kms\_enabled](#input\_kms\_enabled) | (Optional) Enable Azure KeyVault Key Management Service. | `bool` | `false` | no |
| <a name="input_kms_key_vault_key_id"></a> [kms\_key\_vault\_key\_id](#input\_kms\_key\_vault\_key\_id) | (Optional) Identifier of Azure Key Vault key. When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier. | `string` | `null` | no |
| <a name="input_kms_key_vault_network_access"></a> [kms\_key\_vault\_network\_access](#input\_kms\_key\_vault\_network\_access) | (Optional) Network Access of Azure Key Vault. Possible values are: `Private` and `Public`. | `string` | `"Public"` | no |
| <a name="input_kubelet_identity"></a> [kubelet\_identity](#input\_kubelet\_identity) | - `client_id` - (Optional) The Client ID of the user-defined Managed Identity to be assigned to the Kubelets. If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created.<br>- `object_id` - (Optional) The Object ID of the user-defined Managed Identity assigned to the Kubelets.If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created.<br>- `user_assigned_identity_id` - (Optional) The ID of the User Assigned Identity assigned to the Kubelets. If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created. | <pre>object({<br>    client_id                 = optional(string)<br>    object_id                 = optional(string)<br>    user_assigned_identity_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region | `string` | `null` | no |
| <a name="input_load_balancer_profile_enabled"></a> [load\_balancer\_profile\_enabled](#input\_load\_balancer\_profile\_enabled) | (Optional) Enable a load\_balancer\_profile block. This can only be used when load\_balancer\_sku is set to `standard`. | `bool` | `false` | no |
| <a name="input_load_balancer_profile_idle_timeout_in_minutes"></a> [load\_balancer\_profile\_idle\_timeout\_in\_minutes](#input\_load\_balancer\_profile\_idle\_timeout\_in\_minutes) | (Optional) Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between `4` and `120` inclusive. | `number` | `30` | no |
| <a name="input_load_balancer_profile_managed_outbound_ip_count"></a> [load\_balancer\_profile\_managed\_outbound\_ip\_count](#input\_load\_balancer\_profile\_managed\_outbound\_ip\_count) | (Optional) Count of desired managed outbound IPs for the cluster load balancer. Must be between `1` and `100` inclusive | `number` | `null` | no |
| <a name="input_load_balancer_profile_managed_outbound_ipv6_count"></a> [load\_balancer\_profile\_managed\_outbound\_ipv6\_count](#input\_load\_balancer\_profile\_managed\_outbound\_ipv6\_count) | (Optional) The desired number of IPv6 outbound IPs created and managed by Azure for the cluster load balancer. Must be in the range of `1` to `100` (inclusive). The default value is `0` for single-stack and `1` for dual-stack. Note: managed\_outbound\_ipv6\_count requires dual-stack networking. To enable dual-stack networking the Preview Feature Microsoft.ContainerService/AKS-EnableDualStack needs to be enabled and the Resource Provider re-registered, see the documentation for more information. https://learn.microsoft.com/en-us/azure/aks/configure-kubenet-dual-stack?tabs=azure-cli%2Ckubectl#register-the-aks-enabledualstack-preview-feature | `number` | `null` | no | 
| <a name="input_load_balancer_profile_outbound_ip_address_ids"></a> [load\_balancer\_profile\_outbound\_ip\_address\_ids](#input\_load\_balancer\_profile\_outbound\_ip\_address\_ids) | (Optional) The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer. | `set(string)` | `null` | no |
| <a name="input_load_balancer_profile_outbound_ip_prefix_ids"></a> [load\_balancer\_profile\_outbound\_ip\_prefix\_ids](#input\_load\_balancer\_profile\_outbound\_ip\_prefix\_ids) | (Optional) The ID of the outbound Public IP Address Prefixes which should be used for the cluster load balancer. | `set(string)` | `null` | no |
| <a name="input_load_balancer_profile_outbound_ports_allocated"></a> [load\_balancer\_profile\_outbound\_ports\_allocated](#input\_load\_balancer\_profile\_outbound\_ports\_allocated) | (Optional) Number of desired SNAT port for each VM in the clusters load balancer. Must be between `0` and `64000` inclusive. Defaults to `0` | `number` | `0` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | (Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new kubernetes cluster to be created. | `string` | `"standard"` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | (Optional) - If `true` local accounts will be disabled. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts) for more information. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of cluster, if not defined it will be read from the resource-group | `string` | `null` | no |
| <a name="input_log_analytics_solution"></a> [log\_analytics\_solution](#input\_log\_analytics\_solution) | (Optional) Object which contains existing azurerm\_log\_analytics\_solution ID. Providing ID disables creation of azurerm\_log\_analytics\_solution. | <pre>object({<br>    id = string<br>  })</pre> | `null` | no |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | (Optional) Existing azurerm\_log\_analytics\_workspace to attach azurerm\_log\_analytics\_solution. Providing the config disables creation of azurerm\_log\_analytics\_workspace. | <pre>object({<br>    id                  = string<br>    name                = string<br>    location            = optional(string)<br>    resource_group_name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_log_analytics_workspace_enabled"></a> [log\_analytics\_workspace\_enabled](#input\_log\_analytics\_workspace\_enabled) | Enable the integration of azurerm\_log\_analytics\_workspace and azurerm\_log\_analytics\_solution: https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-onboard | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_resource_group_name"></a> [log\_analytics\_workspace\_resource\_group\_name](#input\_log\_analytics\_workspace\_resource\_group\_name) | (Optional) Resource group name to create azurerm\_log\_analytics\_solution. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018 | `string` | `"PerGB2018"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period for the logs in days | `number` | `30` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Maintenance configuration of the managed cluster. | <pre>object({<br>    allowed = optional(list(object({<br>      day   = string<br>      hours = set(number)<br>      })), [<br>    ]),<br>    not_allowed = optional(list(object({<br>      end   = string<br>      start = string<br>    })), []),<br>  })</pre> | `null` | no |      
| <a name="input_maintenance_window_auto_upgrade"></a> [maintenance\_window\_auto\_upgrade](#input\_maintenance\_window\_auto\_upgrade) | - `day_of_month` - (Optional) The day of the month for the maintenance run. Required in combination with RelativeMonthly frequency. Value between 0 and 31 (inclusive).<br>- `day_of_week` - (Optional) The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with weekly frequency.<br>- `duration` - (Required) The duration of the window for maintenance to run in hours.<br>- `frequency` - (Required) Frequency of maintenance. Possible options are `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.<br>- `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.<br>- `start_date` - (Optional) The date on which the maintenance window begins to take effect.<br>- `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.<br>- `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.<br>- `week_index` - (Optional) The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.<br><br>---<br>`not_allowed` block supports the following:<br>- `end` - (Required) The end of a time span, formatted as an RFC3339 string.<br>- `start` - (Required) The start of a time span, formatted as an RFC3339 string. | <pre>object({<br>    day_of_month = optional(number)<br>    day_of_week  = optional(string)<br>    duration     = number<br>    frequency    = string<br>    interval     = number<br>    start_date   = optional(string)<br>    start_time   = optional(string)<br>    utc_offset   = optional(string)<br>    week_index   = optional(string)<br>    not_allowed = optional(set(object({<br>      end   = string<br>      start = string<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_maintenance_window_node_os"></a> [maintenance\_window\_node\_os](#input\_maintenance\_window\_node\_os) | - `day_of_month` -<br>- `day_of_week` - (Optional) The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with weekly frequency.<br>- `duration` - (Required) The duration of the window for maintenance to run in hours.<br>- `frequency` - (Required) Frequency of maintenance. Possible options are `Daily`, `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.<br>- `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.<br>- `start_date` - (Optional) The date on which the maintenance window begins to take effect.<br>- `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.<br>- `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.<br>- `week_index` - (Optional) The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.<br><br>---<br>`not_allowed` block supports the following:<br>- `end` - (Required) The end of a time span, formatted as an RFC3339 string.<br>- `start` - (Required) The start of a time span, formatted as an RFC3339 string. | <pre>object({<br>    day_of_month = optional(number)<br>    day_of_week  = optional(string)<br>    duration     = number<br>    frequency    = string<br>    interval     = number<br>    start_date   = optional(string)<br>    start_time   = optional(string)<br>    utc_offset   = optional(string)<br>    week_index   = optional(string)<br>    not_allowed = optional(set(object({<br>      end   = string<br>      start = string<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_microsoft_defender_enabled"></a> [microsoft\_defender\_enabled](#input\_microsoft\_defender\_enabled) | (Optional) Is Microsoft Defender on the cluster enabled? Requires `var.log_analytics_workspace_enabled` to be `true` to set this variable to `true`. | `bool` | `false` | no |
| <a name="input_monitor_metrics"></a> [monitor\_metrics](#input\_monitor\_metrics) | (Optional) Specifies a Prometheus add-on profile for the Kubernetes Cluster<br>object({<br>  annotations\_allowed = "(Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric."<br>  labels\_allowed      = "(Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric."<br>}) | <pre>object({<br>    annotations_allowed = optional(string)<br>    labels_allowed      = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_msi_auth_for_monitoring_enabled"></a> [msi\_auth\_for\_monitoring\_enabled](#input\_msi\_auth\_for\_monitoring\_enabled) | (Optional) Is managed identity authentication for monitoring enabled? | `bool` | `null` | no |
| <a name="input_net_profile_dns_service_ip"></a> [net\_profile\_dns\_service\_ip](#input\_net\_profile\_dns\_service\_ip) | (Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_net_profile_outbound_type"></a> [net\_profile\_outbound\_type](#input\_net\_profile\_outbound\_type) | (Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer. | `string` | `"loadBalancer"` | no |
| <a name="input_net_profile_pod_cidr"></a> [net\_profile\_pod\_cidr](#input\_net\_profile\_pod\_cidr) | (Optional) The CIDR to use for pod IP addresses. This field can only be set when network\_plugin is set to kubenet. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_net_profile_service_cidr"></a> [net\_profile\_service\_cidr](#input\_net\_profile\_service\_cidr) | (Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_network_contributor_role_assigned_subnet_ids"></a> [network\_contributor\_role\_assigned\_subnet\_ids](#input\_network\_contributor\_role\_assigned\_subnet\_ids) | Create role assignments for the AKS Service Principal to be a Network Contributor on the subnets used for the AKS Cluster, key should be static string, value should be subnet's id | `map(string)` | `{}` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin to use for networking. | `string` | `"kubenet"` | no |
| <a name="input_network_plugin_mode"></a> [network\_plugin\_mode](#input\_network\_plugin\_mode) | (Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is `Overlay`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_node_os_channel_upgrade"></a> [node\_os\_channel\_upgrade](#input\_node\_os\_channel\_upgrade) | (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`. | `string` | `null` | no |
| <a name="input_node_resource_group"></a> [node\_resource\_group](#input\_node\_resource\_group) | The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_nodes_pools"></a> [nodes\_pools](#input\_nodes\_pools) | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | `[]` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable or Disable the OIDC issuer URL. Defaults to false. | `bool` | `false` | no |
| <a name="input_only_critical_addons_enabled"></a> [only\_critical\_addons\_enabled](#input\_only\_critical\_addons\_enabled) | (Optional) Enabling this option will taint default node pool with `CriticalAddonsOnly=true:NoSchedule` taint. Changing this forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_open_service_mesh_enabled"></a> [open\_service\_mesh\_enabled](#input\_open\_service\_mesh\_enabled) | Is Open Service Mesh enabled? For more details, please visit [Open Service Mesh for AKS](https://docs.microsoft.com/azure/aks/open-service-mesh-about). | `bool` | `null` | no |
| <a name="input_orchestrator_version"></a> [orchestrator\_version](#input\_orchestrator\_version) | Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region | `string` | `null` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | Disk size of nodes in GBs. | `number` | `50` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created. | `string` | `"Managed"` | no |
| <a name="input_os_sku"></a> [os\_sku](#input\_os\_sku) | (Optional) Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if OSType=Linux or `Windows2019` if OSType=Windows. And the default Windows OSSKU will be changed to `Windows2022` after Windows2019 is deprecated. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_pod_subnet_id"></a> [pod\_subnet\_id](#input\_pod\_subnet\_id) | (Optional) The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Optional) The prefix for the resources created in the specified Azure Resource Group. Omitting this variable requires both `var.cluster_log_analytics_workspace_name` and `var.cluster_name` have been set. | `string` | `""` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | If true cluster API server will be exposed only on internal IP address and available only in cluster vnet. | `bool` | `false` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | (Optional) Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | (Optional) Either the ID of Private DNS Zone which should be delegated to this Cluster, `System` to have AKS manage this or `None`. In case of `None` you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_public_ssh_key"></a> [public\_ssh\_key](#input\_public\_ssh\_key) | A custom ssh key to control access to the AKS cluster. Changing this forces a new resource to be created. | `string` | `""` | no |   
| <a name="input_rbac_aad"></a> [rbac\_aad](#input\_rbac\_aad) | (Optional) Is Azure Active Directory integration enabled? | `bool` | `true` | no |
| <a name="input_rbac_aad_admin_group_object_ids"></a> [rbac\_aad\_admin\_group\_object\_ids](#input\_rbac\_aad\_admin\_group\_object\_ids) | Object ID of groups with admin access. | `list(string)` | `null` | no |     
| <a name="input_rbac_aad_azure_rbac_enabled"></a> [rbac\_aad\_azure\_rbac\_enabled](#input\_rbac\_aad\_azure\_rbac\_enabled) | (Optional) Is Role Based Access Control based on Azure AD enabled? | `bool` | `null` | no |
| <a name="input_rbac_aad_client_app_id"></a> [rbac\_aad\_client\_app\_id](#input\_rbac\_aad\_client\_app\_id) | The Client ID of an Azure Active Directory Application. | `string` | `null` | no |
| <a name="input_rbac_aad_managed"></a> [rbac\_aad\_managed](#input\_rbac\_aad\_managed) | Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration. | `bool` | `false` | no |
| <a name="input_rbac_aad_server_app_id"></a> [rbac\_aad\_server\_app\_id](#input\_rbac\_aad\_server\_app\_id) | The Server ID of an Azure Active Directory Application. | `string` | `null` | no |
| <a name="input_rbac_aad_server_app_secret"></a> [rbac\_aad\_server\_app\_secret](#input\_rbac\_aad\_server\_app\_secret) | The Server Secret of an Azure Active Directory Application. | `string` | `null` | no |       
| <a name="input_rbac_aad_tenant_id"></a> [rbac\_aad\_tenant\_id](#input\_rbac\_aad\_tenant\_id) | (Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name to be imported | `string` | n/a | yes |
| <a name="input_role_based_access_control_enabled"></a> [role\_based\_access\_control\_enabled](#input\_role\_based\_access\_control\_enabled) | Enable Role Based Access Control. | `bool` | `false` | no |
| <a name="input_run_command_enabled"></a> [run\_command\_enabled](#input\_run\_command\_enabled) | (Optional) Whether to enable run command for the cluster or not. | `bool` | `true` | no |
| <a name="input_scale_down_mode"></a> [scale\_down\_mode](#input\_scale\_down\_mode) | (Optional) Specifies the autoscaling behaviour of the Kubernetes Cluster. If not specified, it defaults to `Delete`. Possible values include `Delete` and `Deallocate`. Changing this forces a new resource to be created. | `string` | `"Delete"` | no |
| <a name="input_secret_rotation_enabled"></a> [secret\_rotation\_enabled](#input\_secret\_rotation\_enabled) | Is secret rotation enabled? This variable is only used when `key_vault_secrets_provider_enabled` is `true` and defaults to `false` | `bool` | `false` | no |
| <a name="input_secret_rotation_interval"></a> [secret\_rotation\_interval](#input\_secret\_rotation\_interval) | The interval to poll for secret rotation. This attribute is only set when `secret_rotation` is `true` and defaults to `2m` | `string` | `"2m"` | no |
| <a name="input_service_mesh_profile"></a> [service\_mesh\_profile](#input\_service\_mesh\_profile) | `mode` - (Required) The mode of the service mesh. Possible value is `Istio`.<br>`internal_ingress_gateway_enabled` - (Optional) Is Istio Internal Ingress Gateway enabled? Defaults to `true`.<br>`external_ingress_gateway_enabled` - (Optional) Is Istio External Ingress Gateway enabled? Defaults to `true`. | <pre>object({<br>    mode                             = string<br>    internal_ingress_gateway_enabled = optional(bool, true)<br>    external_ingress_gateway_enabled = optional(bool, true)<br>  })</pre> | `null` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are `Free`, `Standard` and `Premium` | `string` | `"Free"` | no |
| <a name="input_snapshot_id"></a> [snapshot\_id](#input\_snapshot\_id) | (Optional) The ID of the Snapshot which should be used to create this default Node Pool. `temporary_name_for_rotation` must be specified when changing this property. | `string` | `null` | no |
| <a name="input_storage_profile_blob_driver_enabled"></a> [storage\_profile\_blob\_driver\_enabled](#input\_storage\_profile\_blob\_driver\_enabled) | (Optional) Is the Blob CSI driver enabled? Defaults to `false` | `bool` | `false` | no |
| <a name="input_storage_profile_disk_driver_enabled"></a> [storage\_profile\_disk\_driver\_enabled](#input\_storage\_profile\_disk\_driver\_enabled) | (Optional) Is the Disk CSI driver enabled? Defaults to `true` | `bool` | `true` | no |
| <a name="input_storage_profile_disk_driver_version"></a> [storage\_profile\_disk\_driver\_version](#input\_storage\_profile\_disk\_driver\_version) | (Optional) Disk CSI Driver version to be used. Possible values are `v1` and `v2`. Defaults to `v1`. | `string` | `"v1"` | no |
| <a name="input_storage_profile_enabled"></a> [storage\_profile\_enabled](#input\_storage\_profile\_enabled) | Enable storage profile | `bool` | `false` | no |
| <a name="input_storage_profile_file_driver_enabled"></a> [storage\_profile\_file\_driver\_enabled](#input\_storage\_profile\_file\_driver\_enabled) | (Optional) Is the File CSI driver enabled? Defaults to `true` | `bool` | `true` | no |
| <a name="input_storage_profile_snapshot_controller_enabled"></a> [storage\_profile\_snapshot\_controller\_enabled](#input\_storage\_profile\_snapshot\_controller\_enabled) | (Optional) Is the Snapshot Controller enabled? Defaults to `true` | `bool` | `true` | no |
| <a name="input_support_plan"></a> [support\_plan](#input\_support\_plan) | The support plan which should be used for this Kubernetes Cluster. Possible values are `KubernetesOfficial` and `AKSLongTermSupport`. | `string` | `"KubernetesOfficial"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Any tags that should be present on the AKS cluster resources | `map(string)` | `{}` | no |
| <a name="input_temporary_name_for_rotation"></a> [temporary\_name\_for\_rotation](#input\_temporary\_name\_for\_rotation) | (Optional) Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing. the `var.agents_size` is no longer ForceNew and can be resized by specifying `temporary_name_for_rotation` | `string` | `null` | no |
| <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled) | Whether enable tracing tags that generated by BridgeCrew Yor. | `bool` | `false` | no |
| <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix) | Default prefix for generated tracing tags | `string` | `"avm_"` | no |
| <a name="input_ultra_ssd_enabled"></a> [ultra\_ssd\_enabled](#input\_ultra\_ssd\_enabled) | (Optional) Used to specify whether the UltraSSD is enabled in the Default Node Pool. Defaults to false. | `bool` | `false` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_web_app_routing"></a> [web\_app\_routing](#input\_web\_app\_routing) | object({<br>  dns\_zone\_id = "(Required) Specifies the ID of the DNS Zone in which DNS entries are created for applications deployed to the cluster when Web App Routing is enabled."<br>}) | <pre>object({<br>    dns_zone_id = string<br>  })</pre> | `null` | no |
| <a name="input_workload_autoscaler_profile"></a> [workload\_autoscaler\_profile](#input\_workload\_autoscaler\_profile) | `keda_enabled` - (Optional) Specifies whether KEDA Autoscaler can be used for workloads.<br>`vertical_pod_autoscaler_enabled` - (Optional) Specifies whether Vertical Pod Autoscaler should be enabled. | <pre>object({<br>    keda_enabled                    = optional(bool, false)<br>    vertical_pod_autoscaler_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable or Disable Workload Identity. Defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aci_connector_linux"></a> [aci\_connector\_linux](#output\_aci\_connector\_linux) | The `aci_connector_linux` block of `azurerm_kubernetes_cluster` resource. |
| <a name="output_aci_connector_linux_enabled"></a> [aci\_connector\_linux\_enabled](#output\_aci\_connector\_linux\_enabled) | Has `aci_connector_linux` been enabled on the `azurerm_kubernetes_cluster` resource? |    
| <a name="output_admin_client_certificate"></a> [admin\_client\_certificate](#output\_admin\_client\_certificate) | The `client_certificate` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block.  Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster. |
| <a name="output_admin_client_key"></a> [admin\_client\_key](#output\_admin\_client\_key) | The `client_key` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. Base64 encoded private key used by clients to authenticate to the Kubernetes cluster. |
| <a name="output_admin_cluster_ca_certificate"></a> [admin\_cluster\_ca\_certificate](#output\_admin\_cluster\_ca\_certificate) | The `cluster_ca_certificate` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster. |
| <a name="output_admin_host"></a> [admin\_host](#output\_admin\_host) | The `host` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. The Kubernetes cluster server host. |
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | The `password` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. A password or token used to authenticate to the Kubernetes cluster. |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | The `username` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. A username used to authenticate to the Kubernetes cluster. |
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | The `azurerm_kubernetes_cluster`'s id. |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | The `aurerm_kubernetes-cluster`'s name. |
| <a name="output_azure_policy_enabled"></a> [azure\_policy\_enabled](#output\_azure\_policy\_enabled) | The `azurerm_kubernetes_cluster`'s `azure_policy_enabled` argument. Should the Azure Policy Add-On be enabled? For more details please visit [Understand Azure Policy for Azure Kubernetes Service](https://docs.microsoft.com/en-ie/azure/governance/policy/concepts/rego-for-aks) |
| <a name="output_azurerm_log_analytics_workspace_id"></a> [azurerm\_log\_analytics\_workspace\_id](#output\_azurerm\_log\_analytics\_workspace\_id) | The id of the created Log Analytics workspace |
| <a name="output_azurerm_log_analytics_workspace_name"></a> [azurerm\_log\_analytics\_workspace\_name](#output\_azurerm\_log\_analytics\_workspace\_name) | The name of the created Log Analytics workspace |
| <a name="output_azurerm_log_analytics_workspace_primary_shared_key"></a> [azurerm\_log\_analytics\_workspace\_primary\_shared\_key](#output\_azurerm\_log\_analytics\_workspace\_primary\_shared\_key) | Specifies the workspace key of the log analytics workspace |
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | The `client_certificate` in the `azurerm_kubernetes_cluster`'s `kube_config` block. Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster. |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | The `client_key` in the `azurerm_kubernetes_cluster`'s `kube_config` block. Base64 encoded private key used by clients to authenticate to the Kubernetes cluster. |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | The `cluster_ca_certificate` in the `azurerm_kubernetes_cluster`'s `kube_config` block. Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster. |
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | The FQDN of the Azure Kubernetes Managed Cluster. |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | The `azurerm_kubernetes_cluster`'s `identity` block. |
| <a name="output_cluster_portal_fqdn"></a> [cluster\_portal\_fqdn](#output\_cluster\_portal\_fqdn) | The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster. |
| <a name="output_cluster_private_fqdn"></a> [cluster\_private\_fqdn](#output\_cluster\_private\_fqdn) | The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster. |
| <a name="output_generated_cluster_private_ssh_key"></a> [generated\_cluster\_private\_ssh\_key](#output\_generated\_cluster\_private\_ssh\_key) | The cluster will use this generated private key as ssh key when `var.public_ssh_key` is empty or null. Private key data in [PEM (RFC 1421)](https://datatracker.ietf.org/doc/html/rfc1421) format. |
| <a name="output_generated_cluster_public_ssh_key"></a> [generated\_cluster\_public\_ssh\_key](#output\_generated\_cluster\_public\_ssh\_key) | The cluster will use this generated public key as ssh key when `var.public_ssh_key` is empty or null. The fingerprint of the public key data in OpenSSH MD5 hash format, e.g. `aa:bb:cc:....` Only available if the selected private key format is compatible, similarly to `public_key_openssh` and the [ECDSA P224 limitations](https://registry.terraform.io/providers/hashicorp/tls/latest/docs#limitations). |
| <a name="output_host"></a> [host](#output\_host) | The `host` in the `azurerm_kubernetes_cluster`'s `kube_config` block. The Kubernetes cluster server host. |
| <a name="output_http_application_routing_zone_name"></a> [http\_application\_routing\_zone\_name](#output\_http\_application\_routing\_zone\_name) | The `azurerm_kubernetes_cluster`'s `http_application_routing_zone_name` argument. The Zone Name of the HTTP Application Routing. |
| <a name="output_ingress_application_gateway"></a> [ingress\_application\_gateway](#output\_ingress\_application\_gateway) | The `azurerm_kubernetes_cluster`'s `ingress_application_gateway` block. |
| <a name="output_ingress_application_gateway_enabled"></a> [ingress\_application\_gateway\_enabled](#output\_ingress\_application\_gateway\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `ingress_application_gateway` block? |
| <a name="output_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#output\_key\_vault\_secrets\_provider) | The `azurerm_kubernetes_cluster`'s `key_vault_secrets_provider` block. |
| <a name="output_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#output\_key\_vault\_secrets\_provider\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `key_vault_secrets_provider` block? |
| <a name="output_kube_admin_config_raw"></a> [kube\_admin\_config\_raw](#output\_kube\_admin\_config\_raw) | The `azurerm_kubernetes_cluster`'s `kube_admin_config_raw` argument. Raw Kubernetes config for the admin account to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled. |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | The `azurerm_kubernetes_cluster`'s `kube_config_raw` argument. Raw Kubernetes config to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | The `azurerm_kubernetes_cluster`'s `kubelet_identity` block. |
| <a name="output_location"></a> [location](#output\_location) | The `azurerm_kubernetes_cluster`'s `location` argument. (Required) The location where the Managed Kubernetes Cluster should be created. |
| <a name="output_network_profile"></a> [network\_profile](#output\_network\_profile) | The `azurerm_kubernetes_cluster`'s `network_profile` block |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | The OIDC issuer URL that is associated with the cluster. |
| <a name="output_oms_agent"></a> [oms\_agent](#output\_oms\_agent) | The `azurerm_kubernetes_cluster`'s `oms_agent` argument. |
| <a name="output_oms_agent_enabled"></a> [oms\_agent\_enabled](#output\_oms\_agent\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `oms_agent` block? |
| <a name="output_open_service_mesh_enabled"></a> [open\_service\_mesh\_enabled](#output\_open\_service\_mesh\_enabled) | (Optional) Is Open Service Mesh enabled? For more details, please visit [Open Service Mesh for AKS](https://docs.microsoft.com/azure/aks/open-service-mesh-about). |
| <a name="output_password"></a> [password](#output\_password) | The `password` in the `azurerm_kubernetes_cluster`'s `kube_config` block. A password or token used to authenticate to the Kubernetes cluster. |
| <a name="output_username"></a> [username](#output\_username) | The `username` in the `azurerm_kubernetes_cluster`'s `kube_config` block. A username used to authenticate to the Kubernetes cluster. |
| <a name="output_web_app_routing_identity"></a> [web\_app\_routing\_identity](#output\_web\_app\_routing\_identity) | The `azurerm_kubernetes_cluster`'s `web_app_routing_identity` block, it's type is a list of object. |
