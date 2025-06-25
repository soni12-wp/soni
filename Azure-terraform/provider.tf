terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "3e78949c-6d98-44a4-a7f5-f4899e7c150d"
}