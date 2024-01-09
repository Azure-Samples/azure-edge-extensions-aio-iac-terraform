locals {
  should_create_aio_resource_provider_register_role = var.should_create_aio_resource_provider_register_role && var.should_create_aio_onboard_sp
  aio_resource_provider_register_role_name          = var.aio_resource_provider_register_role_name != null ? var.aio_resource_provider_register_role_name : "Custom - AIO Resource Provider Register"
}

resource "azurerm_role_definition" "aio_resource_provider_register" {
  count = local.should_create_aio_resource_provider_register_role ? 1 : 0

  name        = "Custom - AIO Resource Provider Register"
  scope       = local.aio_resource_provider_register_role_name
  description = "A custom role that has permission to register the AIO resources"

  permissions {
    actions = [
      "Microsoft.ExtendedLocation/register/action",
      "Microsoft.Kubernetes/register/action",
      "Microsoft.KubernetesConfiguration/register/action",
      "Microsoft.IoTOperationsOrchestrator/register/action",
      "Microsoft.IoTOperationsMQ/register/action",
      "Microsoft.IoTOperationsDataProcessor/register/action",
      "Microsoft.DeviceRegistry/register/action"
    ]
  }

  assignable_scopes = [data.azurerm_client_config.current.subscription_id]
}

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

resource "azurerm_role_assignment" "aio_onboard_sp_resource_provider_register" {
  count        = var.should_create_aio_onboard_sp ? 1 : 0
  scope        = data.azurerm_client_config.current.subscription_id
  principal_id = azuread_service_principal.aio_onboard_sp[0].id

  role_definition_name = azurerm_role_definition.aio_resource_provider_register.name
}