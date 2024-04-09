terraform {
  required_version = ">= 1.1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.97.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }
  }
}
