locals {
  key_vault_name      = var.key_vault_name == null ? "kv-${var.name}" : var.key_vault_name
  key_vault_id        = var.should_create_key_vault ? azurerm_key_vault.kv[0].id : data.azurerm_key_vault.kv[0].id
  key_vault_tenant_id = var.should_create_key_vault ? azurerm_key_vault.kv[0].tenant_id : data.azurerm_key_vault.kv[0].tenant_id
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "kv" {
  count = var.should_create_key_vault ? 1 : 0

  name                = local.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

data "azurerm_key_vault" "kv" {
  count = var.should_create_key_vault ? 0 : 1

  name                = local.key_vault_name
  resource_group_name = var.resource_group_name
}

// Give the admin access to create and update keys/permissions/secrets.
resource "azurerm_key_vault_access_policy" "kv_admin_user" {
  count = var.should_create_key_vault_policies ? 1 : 0

  key_vault_id = local.key_vault_id
  object_id    = var.admin_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  key_permissions = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge",
  "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"]
  certificate_permissions = ["Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List",
  "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "SetIssuers", "Update"]
  storage_permissions = ["Get", "List"]
}

// Create the placeholder secret used by AIO.
resource "random_password" "aio_placeholder" {
  count = var.aio_placeholder_secret_value == null ? 1 : 0

  length  = 18
  special = true
}

locals {
  aio_placeholder_secret = var.aio_placeholder_secret_value != null ? var.aio_placeholder_secret_value : random_password.aio_placeholder[0].result
}

resource "azurerm_key_vault_secret" "aio_placeholder" {
  count = var.should_create_key_vault_policies ? 1 : 0

  name         = "placeholder-secret"
  key_vault_id = local.key_vault_id
  value        = local.aio_placeholder_secret

  depends_on = [
    azurerm_key_vault_access_policy.kv_admin_user
  ]
}

// Give the new service principal Azure Key Vault access policy permissions.
resource "azurerm_key_vault_access_policy" "aio_sp" {
  count = var.should_create_key_vault_policies ? 1 : 0

  key_vault_id = local.key_vault_id
  object_id    = var.aio_sp_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions      = ["Get", "List"]
  key_permissions         = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
  storage_permissions     = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "aio_onboard_sp" {
  count = var.should_create_key_vault_policies ? 1 : 0

  key_vault_id = local.key_vault_id
  object_id    = var.aio_onboard_sp_object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = ["Set", "List"]
}
