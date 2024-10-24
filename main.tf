data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "this" {
  name = local.resource_group_name
}

resource "azurerm_resource_group" "this" {
  count    = var.resource_group_creation_enabled ? 1 : 0
  location = var.location
  name     = local.resource_group_name
}

resource "local_sensitive_file" "server_setup_script" {
  count    = var.bootstrap_output_server_setup_script_enabled ? 1 : 0
  filename = var.bootstrap_output_server_setup_script_path
  content  = local.linux_server_setup
}