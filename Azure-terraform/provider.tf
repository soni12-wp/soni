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
  subscription_id = "c04b8072-59fe-485d-ad27-82d7b44e2805"

}
