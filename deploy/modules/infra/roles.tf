///
// Give the new onboarding service principal permission to create Azure Arc resources.
///

resource "azurerm_role_assignment" "aio_onboard_sp_arc_onboarding" {
  count        = var.should_create_aio_onboard_sp ? 1 : 0
  scope        = module.resource_group.resource_group_id
  principal_id = module.service_principal.service_principal_aio_onboard_object_id

  role_definition_name = "Kubernetes Cluster - Azure Arc Onboarding"
}

resource "azurerm_role_assignment" "aio_onboard_sp_k8s_extension_contributor" {
  count        = var.should_create_aio_onboard_sp ? 1 : 0
  scope        = module.resource_group.resource_group_id
  principal_id = module.service_principal.service_principal_aio_onboard_object_id

  role_definition_name = "Kubernetes Extension Contributor"
}

resource "azurerm_role_assignment" "aio_onboard_sp_resource_group_contributor" {
  count        = var.should_create_aio_onboard_sp ? 1 : 0
  scope        = module.resource_group.resource_group_id
  principal_id = module.service_principal.service_principal_aio_onboard_object_id

  role_definition_name = "Contributor"
}
