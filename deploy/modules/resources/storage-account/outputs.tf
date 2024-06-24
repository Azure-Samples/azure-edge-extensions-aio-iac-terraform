output "name" {
  value       = local.storage_account_name
  description = "The name of the created storage account."
}

output "id" {
  value       = local.storage_account_id
  description = "The id for the storage account."
}

output "primary-key" {
  value       = var.should_create_storage_account ? azurerm_storage_account.storage[0].primary_access_key : data.azurerm_storage_account.storage[0].primary_access_key
  description = "The primary access key of the created storage account."
}

output "connection-string" {
  value       = var.should_create_storage_account ? azurerm_storage_account.storage[0].primary_connection_string : azurerm_storage_account.storage[0].primary_connection_string
  description = "A connection string for the storage account."
}

output "blob-endpoint" {
  value       = var.should_create_storage_account ? azurerm_storage_account.storage[0].primary_blob_endpoint : data.azurerm_storage_account.storage[0].primary_blob_endpoint
  description = "The URL for the blob container."
}

output "storage_container_names" {
  value = [for container in azurerm_storage_container.storage_container : container.name]
}
