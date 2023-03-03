variable "management_cluster_name" {
  description = "Name of the management cluster"
  type        = string
  default     = ""
}

variable "provisioner_name" {
  description = "Provisioner of the cluster"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of this cluster"
  type        = string
  default     = ""
}

variable "environment" {
  description = "we only have two environment - stg and prod"
  type        = string
  default     = ""
}

variable "cluster_group" {
  description = "Name of the cluster group to which this cluster belongs"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels for the resource"
  type        = map(string)
  default     = {}
}

variable "pods_cidr_blocks" {
  description = "CIDRBlocks specifies one or more of IP address ranges. Pod CIDR for Kubernetes pods defaults to 192.168.0.0/16"
  type        = string
  default     = ""
}

variable "services_cidr_blocks" {
  description = "Service CIDR for kubernetes services defaults to 10.96.0.0/12"
  type        = string
  default     = ""
}

variable "k8s_version" {
  description = "(Block List, Min: 1, Max: 1) Kubernetes version distribution for the cluster"
  type        = string
  default     = ""
}

variable "control_plane_class" {
  description = "(String) Control plane instance type"
  type        = string
  default     = ""
}

variable "storage_class" {
  description = "String) Storage Class to be used for storage of the disks which store the root filesystems of the nodes"
  type        = string
  default     = ""
}

variable "worker_node_class" {
  description = "(String) Control plane instance type "
  type        = string
  default     = ""
}

variable "control_plane_high_availability" {
  description = "(Boolean) High Availability or Non High Availability Cluster. HA cluster creates three controlplane machines, and non HA creates just one"
  type        = bool
}

variable "worker_node_count" {
  description = "(String) Count is the number of nodes"
  type        = string
  default     = ""
}

variable "nodepool_name" {
  description = "(String) Name of the nodepool"
  type        = string
  default     = ""
}

variable "nodepool_description" {
  description = "(String) Description for the nodepool"
  type        = string
  default     = ""
}