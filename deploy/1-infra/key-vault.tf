///
// Create an Azure Key Vault which will be used by AIO.
// - Creates the Azure Key Vault.
// - Gives a user full privileges to the key vault.
// - Gives an AIO cluster specific service principal 'Get' and 'List' permissions to be able
//   to pull in secrets into the cluster from key vault.
///

resource "azurerm_key_vault" "aio_kv" {
  name                = "kv-${var.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

// Give the admin access to create and update keys/permissions/secrets.

resource "azurerm_key_vault_access_policy" "aio_kv_admin_user" {
  key_vault_id = azurerm_key_vault.aio_kv.id
  object_id    = local.admin_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  key_permissions = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge",
  "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"]
  certificate_permissions = ["Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List",
  "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "SetIssuers", "Update"]
  storage_permissions = ["Get", "List"]
}

// If admin client id was provided, then give current client id access to create secret for placeholder-secret

resource "azurerm_key_vault_access_policy" "aio_kv_current_user" {
  count        = var.admin_object_id != null ? 1 : 0
  key_vault_id = azurerm_key_vault.aio_kv.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = ["Get", "List", "Set"]
}

// Create the placeholder secret used by AIO.

resource "azurerm_key_vault_secret" "aio_placeholder" {
  name         = "placeholder-secret"
  key_vault_id = azurerm_key_vault.aio_kv.id
  value        = var.aio_placeholder_secret_value

  depends_on = [
    azurerm_key_vault_access_policy.aio_kv_admin_user,
    azurerm_key_vault_access_policy.aio_kv_current_user
  ]
}

// Give the new service principal Azure Key Vault access policy permissions.

resource "azurerm_key_vault_access_policy" "aio_sp" {
  key_vault_id = azurerm_key_vault.aio_kv.id
  object_id    = local.aio_sp_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions      = ["Get", "List"]
  key_permissions         = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
  storage_permissions     = ["Get", "List"]
}

