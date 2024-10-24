output "key_vault_name" {
  description = "The new key vault name."
  value       = azurerm_key_vault.this.name
}

output "key_vault_id" {
  description = "The new key vault id."
  value       = azurerm_key_vault.this.id
}