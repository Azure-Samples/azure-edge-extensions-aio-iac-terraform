module "bootstrap_rbac" {
  count = alltrue([var.bootstrap_enabled, var.bootstrap_rbac_creation_enabled]) ? 1 : 0

  source = "modules/bootstrap-rbac"

  admin_object_id                  = local.admin_object_id
  admin_role_assignment_enabled    = var.bootstrap_rbac_admin_role_assignment_enabled
  location                         = var.location
  onboard_sp_object_id             = local.onboard_sp_object_id
  postfix                          = var.postfix
  resource_group_name              = local.resource_group_name
  secret_sync_msi_creation_enabled = var.bootstrap_rbac_secret_sync_msi_creation_enabled
  secret_sync_msi_name             = var.bootstrap_rbac_secret_sync_msi_name
}