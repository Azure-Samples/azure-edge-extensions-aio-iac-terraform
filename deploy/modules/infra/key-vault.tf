locals {
  azure_key_vault_name = coalesce(var.azure_key_vault_name, "kv-${var.name}")
  azure_key_vault_id   = var.should_create_azure_key_vault ? azurerm_key_vault.aio_kv[0].id : data.azurerm_key_vault.aio_kv[0].id
}

///
// Create an Azure Key Vault which will be used by AIO.
// - Creates the Azure Key Vault.
// - Gives a user full privileges to the key vault.
// - Gives an AIO cluster specific service principal 'Get' and 'List' permissions to be able
//   to pull in secrets into the cluster from key vault.
///

resource "azurerm_key_vault" "aio_kv" {
  count = var.should_create_azure_key_vault ? 1 : 0

  name                = local.azure_key_vault_name
  location            = var.location
  resource_group_name = local.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

data "azurerm_key_vault" "aio_kv" {
  count = var.should_create_azure_key_vault ? 0 : 1

  name                = local.azure_key_vault_name
  resource_group_name = local.resource_group_name
}

// Give the admin access to create and update keys/permissions/secrets.

resource "azurerm_key_vault_access_policy" "aio_kv_admin_user" {
  key_vault_id = local.azure_key_vault_id
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
  key_vault_id = local.azure_key_vault_id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = ["Get", "List", "Set"]
}

// Create the placeholder secret used by AIO.

resource "random_password" "aio_placeholder" {
  count   = var.aio_placeholder_secret_value == null ? 1 : 0
  length  = 18
  special = true
}

locals {
  aio_placeholder_secret = var.aio_placeholder_secret_value != null ? var.aio_placeholder_secret_value : random_password.aio_placeholder[0].result
}

resource "azurerm_key_vault_secret" "aio_placeholder" {
  name         = "placeholder-secret"
  key_vault_id = local.azure_key_vault_id
  value        = local.aio_placeholder_secret

  depends_on = [
    azurerm_key_vault_access_policy.aio_kv_admin_user,
    azurerm_key_vault_access_policy.aio_kv_current_user
  ]
}

// Give the new service principal Azure Key Vault access policy permissions.

resource "azurerm_key_vault_access_policy" "aio_sp" {
  key_vault_id = local.azure_key_vault_id
  object_id    = local.aio_sp_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions      = ["Get", "List"]
  key_permissions         = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
  storage_permissions     = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "aio_onboard_sp" {
  key_vault_id = local.azure_key_vault_id
  object_id    = local.aio_onboard_sp_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = ["Set", "List"]
}
