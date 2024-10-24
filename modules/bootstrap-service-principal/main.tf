data "azurerm_client_config" "current" {
}

data "azuread_application_published_app_ids" "well_known" {
}

data "azuread_service_principal" "akv" {
  client_id = data.azuread_application_published_app_ids.well_known.result["AzureKeyVault"]
}

// Get the 'Custom Location RP' ID to use when enabling the Custom Location feature on the cluster.
data "azuread_service_principal" "custom_locations_rp" {
  display_name = "Custom Locations RP"
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

// AIO Service Principal which will have access to Key Vault
resource "azuread_application" "aio_sp" {
  count = var.aio_sp_creation_enabled ? 1 : 0

  display_name = local.aio_sp_name
  owners       = local.owners_admin_object_ids

  required_resource_access {
    resource_app_id = data.azuread_service_principal.akv.client_id

    resource_access {
      id   = data.azuread_service_principal.akv.oauth2_permission_scope_ids["user_impersonation"]
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "aio_sp" {
  count = var.aio_sp_creation_enabled ? 1 : 0

  client_id       = azuread_application.aio_sp[0].client_id
  account_enabled = true
  owners          = local.owners_admin_object_ids
}

resource "azuread_application_password" "aio_sp" {
  count = var.aio_sp_creation_enabled ? 1 : 0

  display_name      = "${local.aio_sp_name}-rbac"
  application_id    = "/applications/${azuread_application.aio_sp[0].object_id}"
  end_date_relative = "4383h" // valid for 6 months then must be rotated for continued use.
}
