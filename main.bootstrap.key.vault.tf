module "bootstrap_key_vault" {
  count = alltrue([
    var.bootstrap_enabled,
    var.bootstrap_key_vault_creation_enabled,
    var.bootstrap_key_vault_aio_policy_creation_enabled,
    var.bootstrap_key_vault_admin_policy_creation_enabled
  ]) ? 1 : 0

  source                          = "modules/bootstrap-key-vault"
  admin_object_id                 = local.admin_object_id
  admin_policy_creation_enabled   = var.bootstrap_key_vault_admin_policy_creation_enabled
  aio_policy_creation_enabled     = var.bootstrap_key_vault_aio_policy_creation_enabled
  aio_sp_object_id                = try(coalesce(var.bootstrap_key_vault_aio_sp_object_id, module.bootstrap_service_principal[0].aio_sp_object_id), null)
  creation_enabled                = var.bootstrap_key_vault_creation_enabled
  location                        = var.location
  name                            = var.bootstrap_key_vault_name
  onboard_object_id               = try(coalesce(var.bootstrap_key_vault_onboard_object_id, module.bootstrap_service_principal[0].onboard_sp_object_id), null)
  onboard_policy_creation_enabled = var.bootstrap_key_vault_onboard_policy_creation_enabled
  postfix                         = var.postfix
  resource_group_name             = coalesce(var.bootstrap_key_vault_resource_group_name, var.resource_group_name)
  sku                             = var.bootstrap_key_vault_sku
}