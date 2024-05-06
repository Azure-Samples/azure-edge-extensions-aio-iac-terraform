output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = local.key_vault_name
}

output "keyvault_id" {
  description = "Id of the Key Vault"
  value       = local.key_vault_id
}

output "keyvault_tenant_id" {
  value = local.key_vault_tenant_id
}
