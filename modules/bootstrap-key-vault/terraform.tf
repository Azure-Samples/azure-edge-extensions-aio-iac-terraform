terraform {
  required_version = ">= 1.4.6"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">=1.9.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
