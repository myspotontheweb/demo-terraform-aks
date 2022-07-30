terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.15.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.6.0"
    }
  }
}

