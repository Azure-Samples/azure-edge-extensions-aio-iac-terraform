locals {
  resource_group_name              = "rg-${var.name}"
  resource_group_id = var.should_create_resource_group ? azurerm_resource_group.rg[0].id : data.azurerm_resource_group.rg[0].id
  location          = var.should_create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
  tags              = var.should_create_resource_group ? azurerm_resource_group.rg[0].tags : data.azurerm_resource_group.rg[0].tags
}

resource "azurerm_resource_group" "rg" {
  count = var.should_create_resource_group ? 1 : 0

  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "rg" {
  count = var.should_create_resource_group ? 0 : 1

  name = local.resource_group_name
}
