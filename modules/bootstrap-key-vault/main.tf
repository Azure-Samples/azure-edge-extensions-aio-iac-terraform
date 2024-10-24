locals {
  key_vault_name = coalesce(var.name, "kv-${var.postfix}")
  tenant_id      = try(azurerm_key_vault.this[0].tenant_id, data.azurerm_client_config.current.tenant_id)
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "this" {
  enable_rbac_authorization = true
  name                      = local.key_vault_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = var.sku
}