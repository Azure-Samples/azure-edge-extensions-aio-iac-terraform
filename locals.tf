locals {
  resource_group_name = coalesce(var.resource_group_name, "rg-${var.postfix}")
}

locals {
  admin_object_id      = coalesce(var.bootstrap_admin_object_id, data.azurerm_client_config.current.object_id)
  arc_resource_name    = coalesce(var.bootstrap_arc_resource_name, "arc-${var.postfix}")
  key_vault_name       = try(coalesce(var.bootstrap_key_vault_name, module.bootstrap_key_vault[0].key_vault_name), "kv-${postfix}")
  resource_group_name  = coalesce(var.resource_group_name, "rg-${var.postfix}")
  onboard_sp_object_id = coalesce(var.bootstrap_onboard_sp_object_id, module.bootstrap_service_principal[0].onboard_sp_object_id)
  onboard_sp_client_id = coalesce(var.bootstrap_onboard_sp_client_id, module.bootstrap_service_principal[0].onboard_sp_client_id)
  onboard_sp_secret    = coalesce(var.bootstrap_onboard_sp_application_password, module.bootstrap_service_principal[0].onboard_sp_application_password)
}

locals {
  server_setup_params = {
    cluster_admin_oid    = local.admin_object_id
    resource_group_name  = local.resource_group_name
    tenant_id            = data.azurerm_client_config.current.tenant_id
    arc_resource_name    = local.arc_resource_name
    subscription_id      = data.azurerm_client_config.current.subscription_id
    location             = var.location
    custom_locations_oid = data.azuread_service_principal.custom_locations_rp.object_id

    aio_kv_name                  = local.key_vault_name
    aio_onboard_sp_client_id     = local.onboard_sp_client_id
    aio_onboard_sp_client_secret = local.onboard_sp_secret
    aio_sp_client_id             = ""
    aio_sp_client_secret         = ""
  }
  linux_server_setup = replace(templatefile("${path.module}/templates/linux.server.setup.sh", local.server_setup_params), "\r\n", "\n")
}