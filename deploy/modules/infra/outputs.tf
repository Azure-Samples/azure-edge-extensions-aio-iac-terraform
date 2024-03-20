output "vm_public_ip" {
  value = azurerm_public_ip.this.ip_address
}

output "ssh_command" {
  value = "ssh -i ${replace(var.vm_ssh_pub_key_file, regex("\\.pub$", var.vm_ssh_pub_key_file), "")} ${var.vm_username}@${azurerm_public_ip.this.ip_address}"
}

output "resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "resource_group_location" {
  value = azurerm_resource_group.this.location
}