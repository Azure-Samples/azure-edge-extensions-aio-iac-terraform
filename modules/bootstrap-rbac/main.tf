data "azurerm_resource_group" "this" {
  name = coalesce(var.resource_group_name, "rg-${var.postfix}")
}

data "azurerm_client_config" "current" {
}

resource "azurerm_user_assigned_identity" "secret_sync" {
  count = var.secret_sync_msi_creation_enabled ? 1 : 0

  name                = local.secret_sync_managed_identity_name
  location            = var.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_role_assignment" "admin_key_vault_secrets_officer" {
  count = var.admin_role_assignment_enabled ? 1 : 0

  scope        = var.key_vault_id
  principal_id = local.admin_object_id

  role_definition_name = "Key Vault Secrets Officer"
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
