output "bootstrap_onboard_sp_object_id" {
  description = "The bootstrapped service principal object id for onboarding cluster to arc."
  value       = try(module.bootstrap_service_principal[0].onboard_sp_object_id, null)
}

output "bootstrap_onboard_sp_client_id" {
  description = "The bootstrapped service principal client id for onboarding cluster to arc."
  value       = try(module.bootstrap_service_principal[0].onboard_sp_client_id, null)
}

output "bootstrap_onboard_sp_application_password" {
  description = "The bootstrapped service principal secret for onboarding cluster to arc."
  value       = try(module.bootstrap_service_principal[0].onboard_sp_application_password, null)
  sensitive   = true
}

output "bootstrap_key_vault_id" {
  description = "The bootstrapped key vault resource id."
  value       = try(module.bootstrap_key_vault[0].key_vault_id, null)
}

output "bootstrap_key_vault_name" {
  description = "The name of the bootstrapped kay vault."
  value       = try(module.bootstrap_key_vault[0].key_vault_name, null)
}

output "bootstrap_secret_sync_msi_id" {
  description = "The secret sync managed identity resource id."
  value       = try(module.bootstrap_rbac[0].secret_sync_msi_id, null)
}

output "custom_locations_rp_object_id" {
  description = "The custom locations RP object id."
  value       = data.azuread_service_principal.custom_locations_rp.object_id
}

output "server_setup_script" {
  description = "The server setup script to run on the server that will have the cluster and AIO"
  value       = local.linux_server_setup
}
