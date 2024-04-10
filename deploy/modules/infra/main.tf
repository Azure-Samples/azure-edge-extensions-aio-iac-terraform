///
// Creates the main infrastructure for AIO.
// - A new Standard D4v5 VM with Ubuntu or Windows.
// - Public IP and NIC for the VM plugged into the VNet.
// - Azure VM Extension script to deploy the K3S and connect to Arc from the VM.
///

locals {
  resource_group_name = coalesce(var.resource_group_name, "rg-${var.name}")
  resource_group_id   = var.should_create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id

  arc_resource_name = "arc-${var.name}"
  arc_cluster_id    = "${local.resource_group_id}/providers/Microsoft.Kubernetes/connectedClusters/${local.arc_resource_name}"

  admin_object_id = var.admin_object_id == null ? data.azurerm_client_config.current.object_id : var.admin_object_id

  aio_onboard_sp_object_id     = var.should_create_aio_onboard_sp ? azuread_service_principal.aio_onboard_sp[0].object_id : var.aio_onboard_sp_object_id
  aio_onboard_sp_client_id     = var.should_create_aio_onboard_sp ? azuread_service_principal.aio_onboard_sp[0].client_id : var.aio_onboard_sp_client_id
  aio_onboard_sp_client_secret = var.should_create_aio_onboard_sp ? azuread_application_password.aio_onboard_sp[0].value : var.aio_onboard_sp_client_secret
  aio_sp_object_id             = var.should_create_aio_akv_sp ? azuread_service_principal.aio_sp[0].object_id : var.aio_akv_sp_client_id
  aio_sp_client_id             = var.should_create_aio_akv_sp ? azuread_service_principal.aio_sp[0].client_id : var.aio_akv_sp_client_id
  aio_sp_client_secret         = var.should_create_aio_akv_sp ? azuread_application_password.aio_sp[0].value : var.aio_akv_sp_client_secret
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "this" {
  count = var.should_create_resource_group ? 1 : 0

  name     = local.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "this" {
  count = var.should_create_resource_group ? 0 : 1

  name = local.resource_group_name
}

resource "azurerm_public_ip" "this" {
  name                = "ip-${var.name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

///
// Deploys a large enough VM that has:
// - Enough memory and cpu to run the AIO workloads.
// - Hypervisor support if using Windows for AKS EE.
///

// TODO: Windows VM setup is currently not implemented. Requires install script similar to linux-vm-setup.tftpl.sh
/*
resource "azurerm_windows_virtual_machine" "this" {
  count = var.should_use_linux ? 0 : 1

  name                                                   = "vm-${var.name}"
  resource_group_name                                    = local.resource_group_name
  location                                               = var.location
  size                                                   = "Standard_D4_v5"
  computer_name                                          = var.vm_computer_name
  admin_username                                         = var.vm_username
  admin_password                                         = var.vm_password
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
*/

resource "azurerm_linux_virtual_machine" "this" {
  count = var.should_use_linux ? 1 : 0

  name                  = "vm-${var.name}"
  resource_group_name   = local.resource_group_name
  location              = var.location
  size                  = var.vm_size
  computer_name         = var.vm_computer_name
  admin_username        = var.vm_username
  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = var.vm_username
    public_key = file(var.vm_ssh_pub_key_file)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_key_vault_access_policy.aio_kv_admin_user,
    azurerm_key_vault_access_policy.aio_kv_current_user,
    azurerm_key_vault_access_policy.aio_onboard_sp,
    azurerm_key_vault_access_policy.aio_sp,
  ]
}

///
// Send a script to the VM that does the following:
// - Configures the VM to support AIO.
// - Downloads and installs a Kubernetes cluster.
// - Connects the new cluster to Azure Arc in the new Resource Group.
// - Initial cluster pre-requisites to support AIO.
///

locals {
  aio_default_spc_params = {
    aio_spc_name          = var.aio_spc_name
    aio_cluster_namespace = var.aio_cluster_namespace
    aio_kv_name           = azurerm_key_vault.aio_kv.name
    aio_tenant_id         = data.azurerm_client_config.current.tenant_id
  }
  aio_ca_cert_trust_secret_params = {
    aio_trust_secret_name = var.aio_trust_secret_name
    aio_cluster_namespace = var.aio_cluster_namespace
    aio_ca_cert_pem       = base64encode(tls_self_signed_cert.ca.cert_pem)
    aio_ca_key_pem        = base64encode(tls_private_key.ca.private_key_pem)
  }
  linux_vm_setup_params = {
    tenant_id         = data.azurerm_client_config.current.tenant_id
    subscription_id   = data.azurerm_client_config.current.subscription_id
    location          = var.location
    cluster_admin_oid = local.admin_object_id

    resource_group_name = local.resource_group_name

    arc_resource_name            = local.arc_resource_name
    aio_onboard_sp_client_id     = local.aio_onboard_sp_client_id
    aio_onboard_sp_client_secret = local.aio_onboard_sp_client_secret

    public_ip = azurerm_public_ip.this.ip_address

    custom_locations_oid = data.azuread_service_principal.custom_locations_rp.object_id

    aio_cluster_namespace     = var.aio_cluster_namespace
    aio_kv_name               = azurerm_key_vault.aio_kv.name
    aio_akv_sp_secret_name    = var.aio_akv_sp_secret_name
    aio_default_spc           = templatefile("${path.module}/manifests/aio-default-spc.tftpl.yaml", local.aio_default_spc_params)
    aio_sp_client_id          = local.aio_sp_client_id
    aio_sp_client_secret      = local.aio_sp_client_secret
    aio_trust_config_map_name = var.aio_trust_config_map_name
    aio_ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
    aio_ca_cert_trust_secret  = templatefile("${path.module}/manifests/aio-ca-cert-trust-secret.tftpl.yaml", local.aio_ca_cert_trust_secret_params)
  }

  linux_vm_setup = templatefile("${path.module}/scripts/linux-vm-setup.tftpl.sh", local.linux_vm_setup_params)
}

// Only use for debugging the linux-vm-setup.sh script.
// Outputs the generated linux-vm-setup.sh script to the <project>/out directory.
/*
resource "local_sensitive_file" "linux_vm_setup" {
  count    = var.should_use_linux ? 1 : 0
  filename = "../../out/linux-vm-setup.sh"
  content  = local.linux_vm_setup
}
*/

// Downloads and runs at /var/lib/waagent/custom-script/download/0 on the VM.
// If there are problems then check the logs at the following locations on the VM.
// - stdout -> /var/lib/waagent/custom-script/download/0/stdout
// - stderr -> /var/lib/waagent/custom-script/download/0/stderr
resource "azurerm_virtual_machine_extension" "linux_setup" {
  count                       = var.should_use_linux ? 1 : 0
  name                        = "linux-vm-setup"
  virtual_machine_id          = azurerm_linux_virtual_machine.this[0].id
  publisher                   = "Microsoft.Azure.Extensions"
  type                        = "CustomScript"
  type_handler_version        = "2.1"
  automatic_upgrade_enabled   = false
  auto_upgrade_minor_version  = false
  failure_suppression_enabled = false
  protected_settings          = <<SETTINGS
  {
    "script": "${base64encode(local.linux_vm_setup)}"
  }
  SETTINGS
}
