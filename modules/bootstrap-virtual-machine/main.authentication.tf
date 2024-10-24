resource "random_password" "admin_password" {
  count = var.admin_password_creation_enabled ? 1 : 0

  length           = 22
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  override_special = "!#$%&()*+,-./:;<=>?@[]^_{|}~"
  special          = true
}

#store the initial password in the secrets key vault
#Requires that the deployment user has key vault secrets write access
resource "azurerm_key_vault_secret" "admin_password" {
  count = var.admin_password_creation_enabled ? 1 : 0

  key_vault_id = var.key_vault_id
  name         = "${local.virtual_machine_name}-${var.admin_username}-password"
  value        = coalesce(var.admin_password, random_password.admin_password[0].result)
}