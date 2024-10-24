resource "azurerm_linux_virtual_machine" "this" {
  name                            = local.virtual_machine_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  computer_name                   = coalesce(var.computer_name, local.virtual_machine_name)
  admin_username                  = var.admin_username
  admin_password                  = coalesce(var.admin_password, random_password.admin_password[0].result)
  disable_password_authentication = false
  patch_assessment_mode           = "AutomaticByPlatform"
  patch_mode                      = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.this[0].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [azurerm_key_vault_secret.admin_password]
}

resource "azurerm_virtual_machine_extension" "linux_setup" {
  count = var.setup_script_enabled ? 1 : 0

  name                        = "linux-vm-setup"
  virtual_machine_id          = azurerm_linux_virtual_machine.this.id
  publisher                   = "Microsoft.Azure.Extensions"
  type                        = "CustomScript"
  type_handler_version        = "2.1"
  automatic_upgrade_enabled   = false
  auto_upgrade_minor_version  = false
  failure_suppression_enabled = false
  protected_settings          = <<SETTINGS
  {
    "script": "${base64encode(var.setup_script)}"
  }
  SETTINGS
}

