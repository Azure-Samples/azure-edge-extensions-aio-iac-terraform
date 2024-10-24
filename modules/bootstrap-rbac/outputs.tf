output "secret_sync_msi_id" {
  description = "The resource id for the managed identity for the secret sync controller."
  value       = azurerm_user_assigned_identity.secret_sync[0].id
}