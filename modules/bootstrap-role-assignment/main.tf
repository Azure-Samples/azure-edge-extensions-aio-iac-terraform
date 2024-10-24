data "azurerm_resource_group" "this" {
  name = coalesce(var.resource_group_name, "rg-${var.postfix}")
}

resource "azurerm_role_assignment" "aio_onboard_sp_arc_onboarding" {
  scope        = data.azurerm_resource_group.this.id
  principal_id = var.onboard_sp_object_id

  role_definition_name = "Kubernetes Cluster - Azure Arc Onboarding"
}

resource "azurerm_role_assignment" "aio_onboard_sp_k8s_extension_contributor" {
  scope        = data.azurerm_resource_group.this.id
  principal_id = var.onboard_sp_object_id

  role_definition_name = "Kubernetes Extension Contributor"
}
