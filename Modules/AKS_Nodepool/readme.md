# AKS Nodepool Module

## Module Usage

***main.tf***
```hcl
data "azurerm_kubernetes_cluster" "cluster_id" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

module "aks-nodepool" {
  source                = "git::https://myrepo.com/hce-public/modules.git//AKS_Nodepool?ref=v3.65.0"
  resource_group_name   = var.resource_group_name
  location              = var.location
  kubernetes_cluster_id = data.azurerm_kubernetes_cluster.cluster_id.id
  node_pools            = var.node_pools
}
```
***variables.tf***
```hcl
variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "az-rg-myapp-hce-dev-01"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "The name of the managed Kubernetes Cluster"
  type        = string
  default     = "az-aks-myapp-hce-dev-01"
}

variable "node_pools" {
  description = "For each nodepool, create an object that contain fields"
  default = {
    node1 = {
      name                     = "ubuntu01"
      vm_size                  = "Standard_D2_v5"
      orchestrator_version     = "1.27.7"
      enable_auto_scaling      = false
      os_sku                   = "Ubuntu"
      mode                     = "User"
      os_disk_size_gb          = 128
      os_disk_type             = "Managed"
      node_count               = 3
      min_count                = 0
      max_count                = 0
      max_pods                 = 256
      zones                    = []
      enable_node_public_ip    = false
      node_public_ip_prefix_id = null
      node_labels              = {}
      node_taints              = []
      enable_host_encryption   = false
      max_pods                 = 128
      vnet_subnet_id           = "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
      tags = {
        DataClassification = "internal"
        Owner              = "myteam@mydomain.com"
        Platform           = "cloud"
        Environment        = "nonprod"
      }
    },
    node2 = {
      name                     = "azurelinux02"
      vm_size                  = "Standard_D2_v5"
      orchestrator_version     = "1.27.7"
      enable_auto_scaling      = false
      os_sku                   = "AzureLinux"
      mode                     = "System"
      os_disk_size_gb          = 128
      os_disk_type             = "Managed"
      node_count               = 2
      min_count                = 0
      max_count                = 0
      zones                    = []
      enable_node_public_ip    = false
      node_public_ip_prefix_id = null
      node_labels              = {}
      node_taints              = []
      enable_host_encryption   = false
      max_pods                 = 128
      vnet_subnet_id           = "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"az-snet-nova-hce-dev-01"
      tags = {
        DataClassification = "internal"
        Owner              = "myteam@mydomain.com"
        Platform           = "cloud"
        Environment        = "nonprod"
      }
    }
  }
}
```
***outputs.tf***
```hcl
output "node_pool_info_example" {
  value = module.aks-nodepool.node_pool_info
}
```
***provider.tf***
```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.65.0"
    }
    kubectl = {
      source  = "hashicorp/kubernetes"
      version = "2.18.0"
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
  subscription_id = "<subscription_ID>"
  tenant_id       = "<tenant_ID>"
  features {}
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.65.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster_node_pool.nodepool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#input\_kubernetes\_cluster\_id) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | n/a | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_pool_info"></a> [node\_pool\_info](#output\_node\_pool\_info) | n/a |
