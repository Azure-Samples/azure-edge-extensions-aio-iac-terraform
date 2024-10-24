data "azurerm_client_config" "current" {
}

// Onboarding Service Principal which will have access to create Arc and Arc Extensions
resource "azuread_application" "onboard_sp" {
  count = var.onboard_sp_creation_enabled ? 1 : 0

  display_name = local.onboard_sp_name
  owners       = local.owners_admin_object_ids
}

resource "azuread_service_principal" "onboard_sp" {
  count = var.onboard_sp_creation_enabled ? 1 : 0

  client_id       = azuread_application.onboard_sp[0].client_id
  account_enabled = true
  owners          = local.owners_admin_object_ids
}

resource "azuread_application_password" "onboard_sp" {
  count = var.onboard_sp_creation_enabled ? 1 : 0

  display_name      = "${local.onboard_sp_name}-rbac"
  application_id    = "/applications/${azuread_application.onboard_sp[0].object_id}"
  end_date_relative = "720h" // valid for 30 days then must be rotated for continued use.
}
