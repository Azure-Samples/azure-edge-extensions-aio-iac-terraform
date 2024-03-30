///
// Give the new onboarding service principal permission to create Azure Arc resources.
///

resource "azurerm_role_assignment" "aio_onboard_sp_arc_onboarding" {
  count        = var.should_create_aio_onboard_sp ? 1 : 0
  scope        = azurerm_resource_group.this.id
  principal_id = azuread_service_principal.aio_onboard_sp[0].id

  role_definition_name = "Kubernetes Cluster - Azure Arc Onboarding"
}

resource "azurerm_role_assignment" "aio_onboard_sp_k8s_extension_contributor" {
  count        = var.should_create_aio_onboard_sp ? 1 : 0
  scope        = azurerm_resource_group.this.id
  principal_id = azuread_service_principal.aio_onboard_sp[0].id

  role_definition_name = "Kubernetes Extension Contributor"
}