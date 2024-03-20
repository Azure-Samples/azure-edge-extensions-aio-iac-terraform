///
// Add two new service principals that have the following permissions:
// - Permission to create an Azure Arc resource connected to our new cluster.
// - Permission to get secrets, keys, and certificates from Azure Key Vault.
//
// Note: The following Terraform effectively works the same as `az ad sp create-for-rbac`
///

data "azuread_application_published_app_ids" "well_known" {
}

data "azuread_service_principal" "akv" {
  client_id = data.azuread_application_published_app_ids.well_known.result["AzureKeyVault"]
}

// Get the 'Custom Location RP' ID to use when enabling the Custom Location feature on the cluster.

data "azuread_service_principal" "custom_locations_rp" {
  display_name = "Custom Locations RP"

  depends_on = [terraform_data.register_providers]
}

// Onboarding Service Principal which will have access to create Arc and Arc Extensions

resource "azuread_application" "aio_onboard_sp" {
  count        = var.should_create_aio_onboard_sp ? 1 : 0
  display_name = "sp-${var.name}-onboard"
  owners       = [local.admin_object_id]
}

resource "azuread_application_password" "aio_onboard_sp" {
  count             = var.should_create_aio_onboard_sp ? 1 : 0
  display_name      = "rbac"
  application_id    = "/applications/${azuread_application.aio_onboard_sp[0].object_id}"
  end_date_relative = "4383h" // valid for 6 months then must be rotated for continued use.
}

resource "azuread_service_principal" "aio_onboard_sp" {
  count           = var.should_create_aio_onboard_sp ? 1 : 0
  client_id       = azuread_application.aio_onboard_sp[0].client_id
  account_enabled = true
  owners          = [local.admin_object_id]
}

// AIO Service Principal which will have access to Key Vault

resource "azuread_application" "aio_sp" {
  count        = var.should_create_aio_akv_sp ? 1 : 0
  display_name = "sp-${var.name}-aio"
  owners       = [local.admin_object_id]

  required_resource_access {
    resource_app_id = data.azuread_service_principal.akv.client_id

    resource_access {
      id   = data.azuread_service_principal.akv.oauth2_permission_scope_ids["user_impersonation"]
      type = "Scope"
    }
  }
}

resource "azuread_application_password" "aio_sp" {
  count             = var.should_create_aio_akv_sp ? 1 : 0
  display_name      = "rbac"
  application_id    = "/applications/${azuread_application.aio_sp[0].object_id}"
  end_date_relative = "4383h" // valid for 6 months then must be rotated for continued use.
}

resource "azuread_service_principal" "aio_sp" {
  count           = var.should_create_aio_akv_sp ? 1 : 0
  client_id       = azuread_application.aio_sp[0].client_id
  account_enabled = true
  owners          = [local.admin_object_id]
}
