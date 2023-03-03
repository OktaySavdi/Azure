terraform {
  required_version = ">= 1.1.9"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.44.1"
    }
  }
}
