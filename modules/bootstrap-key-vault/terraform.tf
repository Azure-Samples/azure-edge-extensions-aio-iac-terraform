terraform {
  required_version = ">= 1.4.6"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.15"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
