locals {
  key_vault_name_onboard = var.should_create_aio_onboard_sp ? "sp-${var.name}-onboard" : var.key_vault_name_onboard
  key_vault_name_akv     = var.should_create_aio_akv_sp ? "sp-${var.name}-akv" : var.key_vault_name_akv

  onboard_sp_client_id = var.should_create_aio_onboard_sp ? azuread_application.aio_onboard_sp[0].client_id : data.azuread_application.aio_onboard_sp[0].client_id
  onboard_sp_object_id = var.should_create_aio_onboard_sp ? azuread_application.aio_onboard_sp[0].object_id : data.azuread_application.aio_onboard_sp[0].object_id
  sp_client_id         = var.should_create_aio_akv_sp ? azuread_application.aio_sp_akv[0].client_id : data.azuread_application.aio_sp_akv[0].client_id
  sp_object_id         = var.should_create_aio_akv_sp ? azuread_application.aio_sp_akv[0].object_id : data.azuread_application.aio_sp_akv[0].object_id

  aio_onboard_sp_object_id = var.should_create_aio_onboard_sp ? azuread_service_principal.aio_onboard_sp[0].object_id : data.azuread_application.aio_onboard_sp[0].object_id
  aio_onboard_sp_client_id = var.should_create_aio_onboard_sp ? azuread_service_principal.aio_onboard_sp[0].client_id : data.azuread_service_principal.aio_onboard_sp[0].client_id
  aio_sp_akv_object_id     = var.should_create_aio_akv_sp ? azuread_service_principal.aio_sp_akv[0].object_id : data.azuread_application.aio_sp_akv[0].object_id
  aio_sp_akv_client_id     = var.should_create_aio_akv_sp ? azuread_service_principal.aio_sp_akv[0].client_id : data.azuread_service_principal.aio_sp_akv[0].client_id
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
resource "azuread_application" "aio_onboard_sp" {
  count = var.should_create_aio_onboard_sp ? 1 : 0

  display_name = local.key_vault_name_onboard
  owners       = [var.admin_object_id]
}

data "azuread_application" "aio_onboard_sp" {
  count = var.should_create_aio_onboard_sp ? 0 : 1

  display_name = local.key_vault_name_onboard
}

resource "azuread_service_principal" "aio_onboard_sp" {
  count = var.should_create_aio_onboard_sp ? 1 : 0

  client_id       = local.onboard_sp_client_id
  account_enabled = true
  owners          = [var.admin_object_id]
}

data "azuread_service_principal" "aio_onboard_sp" {
  count = var.should_create_aio_onboard_sp ? 0 : 1

  client_id = local.onboard_sp_client_id
}

resource "azuread_application_password" "aio_onboard_sp" {
  count = var.should_create_aio_onboard_sp ? 1 : 0

  display_name      = "rbac"
  application_id    = "/applications/${local.onboard_sp_object_id}"
  end_date_relative = "720h" // valid for 30 days then must be rotated for continued use.
}

// AIO Service Principal which will have access to Key Vault
resource "azuread_application" "aio_sp_akv" {
  count = var.should_create_aio_akv_sp ? 1 : 0

  display_name = local.key_vault_name_akv
  owners       = [var.admin_object_id]

  required_resource_access {
    resource_app_id = data.azuread_service_principal.akv.client_id

    resource_access {
      id   = data.azuread_service_principal.akv.oauth2_permission_scope_ids["user_impersonation"]
      type = "Scope"
    }
  }
}

data "azuread_application" "aio_sp_akv" {
  count = var.should_create_aio_akv_sp ? 0 : 1

  display_name = local.key_vault_name_akv
}

resource "azuread_service_principal" "aio_sp_akv" {
  count = var.should_create_aio_akv_sp ? 1 : 0

  client_id       = local.sp_client_id
  account_enabled = true
  owners          = [var.admin_object_id]
}

data "azuread_service_principal" "aio_sp_akv" {
  count = var.should_create_aio_onboard_sp ? 0 : 1

  client_id = local.sp_client_id
}

resource "azuread_application_password" "aio_sp_akv" {
  count             = var.should_create_aio_akv_sp ? 1 : 0
  display_name      = "rbac"
  application_id    = "/applications/${local.sp_object_id}"
  end_date_relative = "4383h" // valid for 6 months then must be rotated for continued use.
}
