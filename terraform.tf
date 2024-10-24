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
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source = "hashicorp/local"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}