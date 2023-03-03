**main**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "<your rg>" #change
    storage_account_name = "<your sa>" #change
    container_name       = "<your cn>" #change
    key                  = "/<your directoy>" #change
    subscription_id      = "<your storage account subscription>" #change
  }
}

data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "<your rg>" #change
    storage_account_name = "<your sa>" #change
    container_name       = "<your cn>" #change
    key                  = "/<your directoy>" #change
    subscription_id      = "<your storage account subscription>" #change
  }
}

provider "kubectl" {
  host                   = data.terraform_remote_state.aks.outputs.host
  #username               = data.terraform_remote_state.aks.outputs.username
  #password               = data.terraform_remote_state.aks.outputs.password
  client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.aks.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.ca_certificate)
}

#provider "kubernetes" {
#  config_path    = "C:\\Users\\osavd\\.kube\\config"
#  config_context = "az-aks-hce-aks-stg-01-admin"
#}

module "namespace" {
  source = "git::https://<git_address>/hce-public/modules.git//K8S_Namespace"

  environment = "nonprod"
  namespace   = "example"

  assign_group = {
    users = [
      "11111-1111-1111-1111-1111",
      "11111-1111-1111-1111-1111"
    ]
    groups = [
      "11111-1111-1111-1111-1111",
      "11111-1111-1111-1111-1111"
    ]
  }

  quota = {
    "requests.cpu"           = "1"
    "requests.memory"        = "1Gi"
    "limits.cpu"             = "2"
    "limits.memory"          = "2Gi"
    "configmaps"             = "10"
    "persistentvolumeclaims" = "4"
    "pods"                   = "4"
    "replicationcontrollers" = "20"
    "secrets"                = "10"
    "services"               = "10"
    "services.loadbalancers" = "2"
  }

  limitrange = [
    {
      type = "Container",
      default = {
        cpu    = "200m"
        memory = "1Gi"
      }
      max = {
        cpu    = "500m"
        memory = "2Gi"
      }
    },
    {
      type = "Pod",
      max = {
        cpu    = "500m"
        memory = "2Gi"
      }
    }
  ]

  labels = {
    "role"                         = "admin"
    "app.kubernetes.io/managed-by" = "terraform"
  }

  annotations = {
    "role"                         = "admin"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}
```

## Requirements

Name | Version
-----|--------
terraform | >= 1.1.9
kubernetes | = 2.18.0

## Providers

| Name | Version |
|------|---------|
azurerm | = 3.44.1
kubernetes | = 2.18.0