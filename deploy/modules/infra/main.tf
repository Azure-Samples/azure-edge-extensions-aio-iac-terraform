///
// Creates the main infrastructure for AIO.
// - A new Standard D4v5 VM with Ubuntu or Windows.
// - Public IP and NIC for the VM plugged into the VNet.
// - Azure VM Extension script to deploy the K3S and connect to Arc from the VM.
///

locals {
  resource_name           = "${var.name}-${var.location}"
  resource_name_condensed = "${var.name}${var.location}"
  arc_resource_name       = "arc-${local.resource_name}"
  arc_cluster_id          = "${module.resource_group.resource_group_id}/providers/Microsoft.Kubernetes/connectedClusters/${local.arc_resource_name}"
  create_virtual_machine  = var.should_create_virtual_machine && var.is_linux_server

  admin_object_id = var.admin_object_id == null ? data.azurerm_client_config.current.object_id : var.admin_object_id

  aio_onboard_sp_object_id     = module.service_principal.service_principal_aio_onboard_object_id
  aio_onboard_sp_client_id     = module.service_principal.service_principal_aio_onboard_client_id
  aio_onboard_sp_client_secret = var.aio_sp_onboard_client_secret == null ? module.service_principal.service_principal_aio_onboard_application_password : var.aio_sp_onboard_client_secret
  aio_sp_object_id             = module.service_principal.service_principal_aio_object_id
  aio_sp_client_id             = module.service_principal.service_principal_aio_client_id
  aio_sp_client_secret         = var.aio_sp_client_secret == null ? module.service_principal.service_principal_aio_password : var.aio_sp_client_secret

  aio_default_spc_params = {
    aio_spc_name          = var.aio_spc_name
    aio_cluster_namespace = var.aio_cluster_namespace
    aio_kv_name           = module.key_vault.keyvault_name
    aio_tenant_id         = data.azurerm_client_config.current.tenant_id
  }

  aio_ca_cert_trust_secret_params = {
    aio_trust_secret_name = var.aio_trust_secret_name
    aio_cluster_namespace = var.aio_cluster_namespace
    aio_ca_cert_pem       = base64encode(tls_self_signed_cert.ca.cert_pem)
    aio_ca_key_pem        = base64encode(tls_private_key.ca.private_key_pem)
  }

  server_setup_params = {
    cluster_admin_oid   = local.admin_object_id
    resource_group_name = module.resource_group.resource_group_name
    tenant_id           = data.azurerm_client_config.current.tenant_id
    arc_resource_name   = local.arc_resource_name
    subscription_id     = data.azurerm_client_config.current.subscription_id
    location            = var.location

    aio_cluster_namespace        = var.aio_cluster_namespace
    aio_kv_name                  = module.key_vault.keyvault_name
    aio_akv_sp_secret_name       = var.aio_akv_sp_secret_name
    aio_default_spc              = templatefile("${path.module}/manifests/aio-default-spc.tftpl.yaml", local.aio_default_spc_params)
    aio_onboard_sp_client_id     = local.aio_onboard_sp_client_id
    aio_onboard_sp_client_secret = local.aio_onboard_sp_client_secret
    aio_sp_client_id             = local.aio_sp_client_id
    aio_sp_client_secret         = local.aio_sp_client_secret
    aio_ca_cert_pem              = tls_self_signed_cert.ca.cert_pem
    aio_ca_cert_trust_secret     = templatefile("${path.module}/manifests/aio-ca-cert-trust-secret.tftpl.yaml", local.aio_ca_cert_trust_secret_params)
    aio_trust_config_map_name    = var.aio_trust_config_map_name
    custom_locations_oid         = module.service_principal.custom_locations_rp
  }

  server_setup = var.is_linux_server ? templatefile("${path.module}/scripts/linux-server-setup.sh", local.server_setup_params) : templatefile("${path.module}/scripts/windows-server-setup.sh", local.server_setup_params)
}

data "azurerm_client_config" "current" {
}

module "resource_group" {
  source                       = "../resources/resource-group"
  should_create_resource_group = true

  name     = local.resource_name
  location = var.location
}

module "storage_account" {
  source = "../resources/storage-account"
  count  = var.should_create_storage_account ? 1 : 0

  should_create_storage_account            = true
  should_create_storage_account_containers = true

  depends_on = [module.resource_group]

  name                = local.resource_name_condensed
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name

  storage_account_tier             = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type
  containers                       = var.containers
  container_access_type            = var.container_access_type
}

module "container_registry" {
  source = "../resources/container-registry"
  count  = var.should_create_container_registry ? 1 : 0

  should_create_container_registry = true

  depends_on = [module.resource_group]

  name                = local.resource_name_condensed
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  sku                 = var.container_registry_sku
}

module "key_vault" {
  source = "../resources/key-vault"

  should_create_key_vault          = true
  should_create_key_vault_policies = true

  depends_on = [module.resource_group]

  name                         = local.resource_name
  resource_group_name          = module.resource_group.resource_group_name
  location                     = module.resource_group.resource_group_location
  admin_object_id              = local.admin_object_id
  aio_sp_object_id             = local.aio_sp_object_id
  aio_onboard_sp_object_id     = local.aio_onboard_sp_object_id
  aio_placeholder_secret_value = var.aio_placeholder_secret_value
}

module "service_principal" {
  source = "../resources/service-principal"

  name = local.resource_name

  should_create_onboard_sp        = var.should_create_aio_onboard_sp
  sp_onboard_client_id            = var.aio_sp_onboard_client_id
  should_create_onboard_sp_secret = var.aio_sp_onboard_client_secret == null

  should_create_sp        = var.should_create_aio_sp
  sp_client_id            = var.aio_sp_client_id
  should_create_sp_secret = var.aio_sp_client_secret == null

  admin_object_id = local.admin_object_id
}

resource "azurerm_key_vault_secret" "kv_sp_aio_secret" {
  name         = "sp-aio-secret"
  key_vault_id = module.key_vault.keyvault_id
  value        = module.service_principal.service_principal_aio_password

  depends_on = [module.key_vault, module.service_principal]
}

module "event_hub" {
  source = "../resources/event-hub"
  count  = var.should_use_event_hub ? 1 : 0

  should_create_event_hub_namespace = true

  depends_on = [module.resource_group]

  name                = local.resource_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  should_create_event_hub = false
}

module "event_grid" {
  source = "../resources/event-grid"
  count  = var.should_use_event_grid ? 1 : 0

  should_create_eventgrid_namespace = true

  depends_on = [module.resource_group]

  name              = local.resource_name
  location          = module.resource_group.resource_group_location
  resource_group_id = module.resource_group.resource_group_id

  enable_mqtt_broker              = true
  should_create_event_grid_topics = false
}

module "virtual_machine" {
  source = "../resources/virtual-machine"
  count  = local.create_virtual_machine ? 1 : 0

  should_create_virtual_machine = true
  should_create_network         = true

  depends_on = [
    module.key_vault,
    module.service_principal
  ]

  name                = local.resource_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  vm_computer_name = var.name
  vm_username      = var.name
  vm_password      = random_password.password[0].result
  vm_setup_script  = local.server_setup
  vm_size          = var.vm_size
}

resource "random_password" "password" {
  count = local.create_virtual_machine ? 1 : 0

  length           = 12
  special          = true
  override_special = "!#$%*?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "azurerm_key_vault_secret" "kv_virtual_machine_secret" {
  count = local.create_virtual_machine ? 1 : 0

  name         = "virtual-machine-password"
  key_vault_id = module.key_vault.keyvault_id
  value        = random_password.password[0].result

  depends_on = [module.key_vault]
}
