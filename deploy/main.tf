module "infra" {
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
  source = "./modules/aio-full"

  depends_on = [module.infra]

  name     = var.name
  location = var.location
}

module "opc_plc_sim" {
  source = "./modules/opc-plc-sim"

  depends_on = [module.aio_full]

  name     = var.name
  location = var.location
}

output "vm_public_ip" {
  value = module.infra.vm_public_ip
}

output "ssh_command" {
  value = module.infra.ssh_command
}

output "resource_group_name" {
  value = module.infra.resource_group_name
}