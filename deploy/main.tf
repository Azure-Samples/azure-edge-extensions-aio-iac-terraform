module "infra" {
  count  = var.should_install_infra ? 1 : 0
  source = "./modules/infra"

  name     = var.name
  location = var.location

  should_create_storage_account    = var.should_create_storage_account
  should_create_container_registry = var.should_create_container_registry

  should_create_virtual_machine = var.should_create_virtual_machine
  is_linux_server               = var.is_linux_server
  vm_size                       = var.vm_size

  should_use_event_hub  = var.should_use_event_hub
  should_use_event_grid = var.should_use_event_grid
}

module "aio_full" {
  count  = var.should_install_aio ? 1 : 0
  source = "./modules/aio-full"

  depends_on = [module.infra]

  name     = var.name
  location = var.location

  kubernetes_distro                  = var.kubernetes_distro
  aio_mq_broker_auth_non_tls_enabled = var.aio_mq_broker_auth_non_tls_enabled
  should_deploy_mqtt_client          = var.should_deploy_mqtt_client

  should_use_event_hub  = var.should_use_event_hub
  should_use_event_grid = var.should_use_event_grid
}

module "opc_plc_sim" {
  count  = var.should_install_opc_plc_sim ? 1 : 0
  source = "./modules/opc-plc-sim"

  depends_on = [module.aio_full]

  name             = var.name
  location         = var.location
  arc_cluster_name = module.aio_full[0].aio_cluster_name
}

output "resource_group_name" {
  value = var.should_install_infra ? module.infra[0].resource_group_name : null
}
