output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = local.eventhub_name
}

output "eventhub_namespace_id" {
  description = "ID of the Event Hub namespace"
  value       = local.eventhub_namespace_id
}

output "eventhub_ids" {
  description = "IDs of the Event Hubs"
  value       = [for hub in azurerm_eventhub.eventhub : hub.id]
}

output "default_policy_key" {
  sensitive = true
  value     = local.default_policy_key
}

output "eventhub_namespace_primary_connection_string" {
  description = "Primary connection string of the Event Hub namespace"
  sensitive   = true
  value       = local.primary_connection_string
}
