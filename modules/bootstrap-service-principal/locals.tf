locals {
  onboard_sp_name = "sp-${var.postfix}-onboard"
  aio_sp_name         = "sp-${var.postfix}-akv"

  current_user = data.azurerm_client_config.current
  owners_admin_object_ids = coalesce(var.owners_admin_object_ids, [data.azurerm_client_config.current.object_id])
}

