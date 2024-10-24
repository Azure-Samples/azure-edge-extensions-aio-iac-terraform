module "bootstrap_service_principal" {
  count = alltrue([var.bootstrap_enabled, var.bootstrap_service_principal_creation_enabled]) ? 1 : 0

  source                  = "./modules/bootstrap-service-principal"
  postfix                 = var.postfix
  owners_admin_object_ids = var.bootstrap_service_principal_owners_admin_object_id
}