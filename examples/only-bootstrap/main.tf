module "iot_operations" {
  source   = "../../"
  postfix  = var.postfix
  location = var.location

  resource_group_creation_enabled = true

  bootstrap_enabled                               = true
  bootstrap_output_server_setup_script_enabled    = true
  bootstrap_key_vault_creation_enabled            = true
  bootstrap_rbac_creation_enabled                 = true
  bootstrap_rbac_admin_role_assignment_enabled    = true
  bootstrap_rbac_secret_sync_msi_creation_enabled = true
  bootstrap_service_principal_creation_enabled    = true

  bootstrap_virtual_machine_admin_password_creation_enabled = true
  bootstrap_virtual_machine_creation_enabled                = true
  bootstrap_virtual_machine_network_creation_enabled        = true

  # Do not deploy the setup script just yet
  bootstrap_virtual_machine_setup_script_enabled = false
}