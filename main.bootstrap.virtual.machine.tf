module "bootstrap_virtual_machine" {
  count = alltrue([var.bootstrap_enabled, var.bootstrap_virtual_machine_creation_enabled]) ? 1 : 0

  source                          = "./modules/bootstrap-virtual-machine"
  admin_password                  = var.bootstrap_virtual_machine_admin_password
  admin_password_creation_enabled = var.bootstrap_virtual_machine_admin_password_creation_enabled
  admin_username                  = var.bootstrap_virtual_machine_admin_username
  computer_name                   = var.bootstrap_virtual_machine_computer_name
  key_vault_id                    = try(coalesce(var.bootstrap_virtual_machine_key_vault_id, module.bootstrap_key_vault[0].key_vault_id), null)
  location                        = var.location
  network_creation_enabled        = var.bootstrap_virtual_machine_network_creation_enabled
  postfix                         = var.postfix
  resource_group_name             = try(data.azurerm_resource_group.this[0].name, azurerm_resource_group.this[0].name)
  setup_script                    = local.linux_server_setup
  setup_script_enabled            = var.bootstrap_virtual_machine_setup_script_enabled
  size                            = var.bootstrap_virtual_machine_size
  subnet_address_space            = var.bootstrap_virtual_machine_subnet_address_space
  vnet_address_space              = var.bootstrap_virtual_machine_vnet_address_space
}