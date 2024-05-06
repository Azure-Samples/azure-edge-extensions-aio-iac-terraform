locals {
  storage_account_name = "sa${var.name}"
  storage_account_id   = var.should_create_storage_account ? azurerm_storage_account.storage[0].id : data.azurerm_storage_account.storage[0].id
}

resource "azurerm_storage_account" "storage" {
  count = var.should_create_storage_account ? 1 : 0

  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  tags                     = var.tags
}

data "azurerm_storage_account" "storage" {
  count = var.should_create_storage_account ? 0 : 1

  name                = local.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_container" "storage_container" {
  count = var.should_create_storage_account_containers ? length(var.containers) : 0

  name                  = var.containers[count.index]
  storage_account_name  = local.storage_account_name
  container_access_type = var.container_access_type

  depends_on = [
    azurerm_storage_account.storage
  ]
}
