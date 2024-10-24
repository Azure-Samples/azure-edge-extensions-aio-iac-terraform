module "bootstrap_role_assignment" {
  count = alltrue([var.bootstrap_enabled, var.bootstrap_role_assignment_creation_enabled]) ? 1 : 0

  source = "modules/bootstrap-role-assignment"

  onboard_sp_object_id = local.onboard_sp_object_id
  postfix              = var.postfix
  resource_group_name  = local.resource_group_name
}