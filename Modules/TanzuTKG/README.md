# TMC Module

Terraform module for tmc k8s cluster installation

## Module Usage

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "<resourcegroup_name>"
    storage_account_name = "<my_storageaccount_name>"
    container_name       = "<my_container_name>"
    key                  = "/kubernetes_clusters/staging/hce-k8s.tfstate" #change this directory
  }
}

module "tmc-cluster" {
  source                          = "git::https://<git_address>/hce-public/modules.git//TanzuTKG"
  management_cluster_name         = var.management_cluster_name
  provisioner_name                = var.provisioner_name
  environment                     = var.environment
  cluster_name                    = var.cluster_name
  cluster_group                   = var.cluster_group
  pods_cidr_blocks                = var.pods_cidr_blocks
  services_cidr_blocks            = var.services_cidr_blocks
  k8s_version                     = var.k8s_version
  control_plane_class             = var.control_plane_class
  worker_node_class               = var.worker_node_class
  storage_class                   = var.storage_class
  control_plane_high_availability = var.control_plane_high_availability
  worker_node_count               = var.worker_node_count
  nodepool_name                   = var.nodepool_name
  nodepool_description            = var.nodepool_description
}
```
**variables.tf**
```hcl
variable "management_cluster_name" {
  description = "Name of the management cluster - Possible values stg-tanzuk8s-cl1 and atvcf1-tanzuk8s-cl1"
  type        = string
  default     = "<managememnt_cluster_name>"
}

variable "provisioner_name" {
  description = "Provisioner of the cluster"
  type        = string
  default     = "stg-tns-hce-lab-01"
}

variable "cluster_name" {
  description = "Name of this cluster"
  type        = string
  default     = "hce-sandbox-test"
}

variable "environment" {
  description = "we only have two environment - stg and prod"
  type        = string
  default     = "stg"
}

variable "cluster_group" {
  description = "Name of the cluster group to which this cluster belongs - Possible values cl-staging and cl-production"
  type        = string
  default     = "cl-staging"
}

variable "labels" {
  description = "Labels for the resource"
  type        = map(string)
  default = {
    "environment" : "test"
    #"owner"       = "hce"
  }
}

variable "pods_cidr_blocks" {
  description = "CIDRBlocks specifies one or more of IP address ranges. Pod CIDR for Kubernetes pods defaults to 192.168.0.0/16"
  type        = string
  default     = "172.20.0.0/16"
}

variable "services_cidr_blocks" {
  description = "Service CIDR for kubernetes services defaults to 10.96.0.0/12"
  type        = string
  default     = "10.96.0.0/16"
}

variable "k8s_version" {
  description = "Kubernetes version distribution for the cluster"
  type        = string
  default     = "v1.22.9+vmware.1-tkg.1.cc71bc8"
}

variable "control_plane_class" {
  description = "Control plane instance type"
  type        = string
  default     = "best-effort-xsmall"
}

variable "storage_class" {
  description = "Storage Class to be used for storage of the disks which store the root filesystems of the nodes"
  type        = string
  default     = "<my_storage_class>"
}

variable "worker_node_class" {
  description = "Worker nopde instance type"
  type        = string
  default     = "best-effort-xsmall"
}

variable "control_plane_high_availability" {
  description = "High Availability or Non High Availability Cluster. HA cluster creates three controlplane machines, and non HA creates just one.If false, only 1 controler will be created. if you set true. There will be 3 controllers"
  type        = bool
  default     = false
}

variable "worker_node_count" {
  description = "Count is the number of nodes"
  type        = string
  default     = 1
}

variable "nodepool_name" {
  description = "Name of the nodepool. default node pool name `default-nodepool`"
  type        = string
  default     = "mycompany-nodepool"
}

variable "nodepool_description" {
  description = "Description for the nodepool"
  type        = string
  default     = "tkgs workload nodepool"
}
```
## Requirements

Name | Version
-----|--------
terraform | >= 1.1.9
azurerm | = 3.44.1

## Providers

| Name | Version |
|------|---------|
azurerm | = 3.44.1
vmware/tanzu-mission-control | = 1.1.5
hashicorp/local | = 2.3.0