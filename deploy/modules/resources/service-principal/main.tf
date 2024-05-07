locals {
  sp_onboard_name = var.should_create_onboard_sp ? "sp-${var.name}-onboard" : data.azuread_application.app_reg_onboard[0].display_name
  sp_name         = var.should_create_sp ? "sp-${var.name}-akv" : data.azuread_application.app_reg[0].display_name

  app_reg_onboard_client_id = var.should_create_onboard_sp ? azuread_application.app_reg_onboard[0].client_id : data.azuread_application.app_reg_onboard[0].client_id
  app_reg_onboard_object_id = var.should_create_onboard_sp ? azuread_application.app_reg_onboard[0].object_id : data.azuread_application.app_reg_onboard[0].object_id
  app_reg_client_id         = var.should_create_sp ? azuread_application.app_reg[0].client_id : data.azuread_application.app_reg[0].client_id
  app_reg_object_id         = var.should_create_sp ? azuread_application.app_reg[0].object_id : data.azuread_application.app_reg[0].object_id

  sp_onboard_object_id = var.should_create_onboard_sp ? azuread_service_principal.sp_onboard[0].object_id : data.azuread_service_principal.sp_onboard[0].object_id
  sp_onboard_client_id = var.should_create_onboard_sp ? azuread_service_principal.sp_onboard[0].client_id : data.azuread_service_principal.sp_onboard[0].client_id
  sp_object_id         = var.should_create_sp ? azuread_service_principal.sp[0].object_id : data.azuread_service_principal.sp[0].object_id
  sp_client_id         = var.should_create_sp ? azuread_service_principal.sp[0].client_id : data.azuread_service_principal.sp[0].client_id
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
resource "azuread_application" "app_reg_onboard" {
  count = var.should_create_onboard_sp ? 1 : 0

  display_name = local.sp_onboard_name
  owners       = [var.admin_object_id]
}

data "azuread_application" "app_reg_onboard" {
  count = var.should_create_onboard_sp ? 0 : 1

  client_id = var.sp_onboard_client_id
}

resource "azuread_service_principal" "sp_onboard" {
  count = var.should_create_onboard_sp ? 1 : 0

  client_id       = local.app_reg_onboard_client_id
  account_enabled = true
  owners          = [var.admin_object_id]
}

data "azuread_service_principal" "sp_onboard" {
  count = var.should_create_onboard_sp ? 0 : 1

  client_id = local.app_reg_onboard_client_id
}

resource "azuread_application_password" "sp_onboard" {
  count = var.should_create_onboard_sp_secret ? 1 : 0

  display_name      = "${var.name}-rbac"
  application_id    = "/applications/${local.app_reg_onboard_object_id}"
  end_date_relative = "720h" // valid for 30 days then must be rotated for continued use.
}

// AIO Service Principal which will have access to Key Vault
resource "azuread_application" "app_reg" {
  count = var.should_create_sp ? 1 : 0

  display_name = local.sp_name
  owners       = [var.admin_object_id]

  required_resource_access {
    resource_app_id = data.azuread_service_principal.akv.client_id

    resource_access {
      id   = data.azuread_service_principal.akv.oauth2_permission_scope_ids["user_impersonation"]
      type = "Scope"
    }
  }
}

data "azuread_application" "app_reg" {
  count = var.should_create_sp ? 0 : 1

  client_id = var.sp_client_id
}

resource "azuread_service_principal" "sp" {
  count = var.should_create_sp ? 1 : 0

  client_id       = local.app_reg_client_id
  account_enabled = true
  owners          = [var.admin_object_id]
}

data "azuread_service_principal" "sp" {
  count = var.should_create_sp ? 0 : 1

  client_id = local.app_reg_client_id
}

resource "azuread_application_password" "sp" {
  count = var.should_create_sp_secret ? 1 : 0

  display_name      = "${var.name}-rbac"
  application_id    = "/applications/${local.app_reg_object_id}"
  end_date_relative = "4383h" // valid for 6 months then must be rotated for continued use.
}
