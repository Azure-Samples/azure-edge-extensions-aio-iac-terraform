module "bootstrap_key_vault" {
  count = alltrue([var.bootstrap_enabled, var.bootstrap_key_vault_creation_enabled]) ? 1 : 0

  source              = "modules/bootstrap-key-vault"
  location            = var.location
  name                = var.bootstrap_key_vault_name
  postfix             = var.postfix
  resource_group_name = coalesce(var.bootstrap_key_vault_resource_group_name, var.resource_group_name)
  sku                 = var.bootstrap_key_vault_sku
}