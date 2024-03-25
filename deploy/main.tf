module "infra" {
  count  = var.should_install_infra ? 1 : 0
  source = "./modules/infra"

  name                = var.name
  location            = var.location
  vm_computer_name    = var.vm_computer_name
  vm_username         = var.vm_username
  vm_ssh_pub_key_file = var.vm_ssh_pub_key_file

  vm_size                 = var.vm_size
  vm_storage_account_type = var.vm_storage_account_type
}

module "aio_full" {
  count  = var.should_install_aio ? 1 : 0
  source = "./modules/aio-full"

  depends_on = [module.infra]

  name     = var.name
  location = var.location

  resource_group_name = var.should_install_infra ? null : var.resource_group_name
  arc_cluster_name    = var.should_install_infra ? null : var.arc_cluster_name
  key_vault_name      = var.should_install_infra ? null : var.key_vault_name
}

module "opc_plc_sim" {
  count  = var.should_install_opc_plc_sim ? 1 : 0
  source = "./modules/opc-plc-sim"

  depends_on = [module.aio_full]

  name     = var.name
  location = var.location

  resource_group_name = var.resource_group_name
  arc_cluster_name    = var.arc_cluster_name
}

output "vm_public_ip" {
  value = var.should_install_infra ? module.infra[0].vm_public_ip : null
}

output "ssh_command" {
  value = var.should_install_infra ? module.infra[0].ssh_command : null
}

output "resource_group_name" {
  value = var.should_install_infra ? module.infra[0].resource_group_name : null
}