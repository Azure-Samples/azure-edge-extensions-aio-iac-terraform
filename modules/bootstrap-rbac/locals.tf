locals {
  admin_object_id                   = coalesce(var.admin_object_id, data.azurerm_client_config.current.object_id)
  secret_sync_managed_identity_name = coalesce(var.secret_sync_msi_name, "mi-secret-sync-${var.postfix}")
  resource_group_name               = coalesce(var.resource_group_name, "rg-${var.postfix}")
}