
locals {
  virtual_machine_name = "vm-${var.name}"
  virtual_machine_id   = var.should_create_virtual_machine ? azurerm_linux_virtual_machine.this[0].id : data.azurerm_virtual_machine.this[0].id
}

resource "azurerm_linux_virtual_machine" "this" {
  count = var.should_create_virtual_machine ? 1 : 0

  name                            = local.virtual_machine_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  computer_name                   = var.name
  admin_username                  = var.vm_username
  admin_password                  = var.vm_password
  disable_password_authentication = false
  patch_assessment_mode           = "AutomaticByPlatform"
  patch_mode                      = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.this[0].id,
  ]

  #   admin_ssh_key {
  #     username   = var.vm_username
  #     public_key = file(var.vm_ssh_pub_key_file)
  #   }

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
}

data "azurerm_virtual_machine" "this" {
  count = var.should_create_virtual_machine ? 0 : 1

  name                = local.virtual_machine_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_machine_extension" "linux_setup" {
  name                        = "linux-vm-setup"
  virtual_machine_id          = local.virtual_machine_id
  publisher                   = "Microsoft.Azure.Extensions"
  type                        = "CustomScript"
  type_handler_version        = "2.1"
  automatic_upgrade_enabled   = false
  auto_upgrade_minor_version  = false
  failure_suppression_enabled = false
  protected_settings          = <<SETTINGS
  {
    "script": "${base64encode(var.vm_setup_script)}"
  }
  SETTINGS
}

