locals {
  container_registry_name = "acr${var.name}"
  container_registry_id   = var.should_create_container_registry ? azurerm_container_registry.acr[0].id : data.azurerm_container_registry.acr[0].id
}

resource "azurerm_container_registry" "acr" {
  count = var.should_create_container_registry ? 1 : 0

  name                = local.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true
}

data "azurerm_container_registry" "acr" {
  count = var.should_create_container_registry ? 0 : 1

  name                = local.container_registry_name
  resource_group_name = var.resource_group_name
}
