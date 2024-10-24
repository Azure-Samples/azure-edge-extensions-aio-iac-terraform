locals {
  key_vault_name    = coalesce(var.name, "kv-${var.postfix}")
  key_vault_id      = try(azurerm_key_vault.this[0].id, data.azurerm_key_vault.this[0].id)
  tenant_id         = try(azurerm_key_vault.this[0].tenant_id, data.azurerm_client_config.current.tenant_id)
  onboard_object_id = coalesce(var.onboard_object_id, data.azurerm_client_config.current.object_id)
  admin_object_id   = coalesce(var.admin_object_id, data.azurerm_client_config.current.object_id)
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "this" {
  count = var.creation_enabled ? 1 : 0

  enable_rbac_authorization = false
  name                      = local.key_vault_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = var.sku
}

data "azurerm_key_vault" "this" {
  count = var.creation_enabled ? 0 : 1

  name                = local.key_vault_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_access_policy" "admin" {
  count = var.admin_policy_creation_enabled ? 1 : 0

  key_vault_id = local.key_vault_id
  object_id    = local.admin_object_id
  tenant_id    = local.tenant_id

  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  key_permissions = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge",
  "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"]
  certificate_permissions = ["Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List",
  "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "SetIssuers", "Update"]
  storage_permissions = ["Get", "List"]
}

// Give the admin access to create and update keys/permissions/secrets.
resource "azurerm_key_vault_access_policy" "onboard" {
  count = var.onboard_policy_creation_enabled ? 1 : 0

  key_vault_id = local.key_vault_id
  object_id    = local.onboard_object_id
  tenant_id    = local.tenant_id

  secret_permissions = ["Set"]
}

// Give the new service principal Azure Key Vault access policy permissions.
resource "azurerm_key_vault_access_policy" "aio" {
  count = var.aio_policy_creation_enabled ? 1 : 0

  key_vault_id = local.key_vault_id
  object_id    = var.aio_sp_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions      = ["Get", "List"]
  key_permissions         = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
  storage_permissions     = ["Get", "List"]
}
