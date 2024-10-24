output "onboard_sp_object_id" {
  description = "The service principal object id for onboarding cluster to arc."
  value       = azuread_service_principal.onboard_sp.object_id
}

output "onboard_sp_client_id" {
  description = "The service principal client id for onboarding cluster to arc."
  value       = azuread_service_principal.onboard_sp.client_id
}

output "onboard_sp_application_password" {
  description = "The service principal secret for onboarding cluster to arc."
  value       = azuread_application_password.onboard_sp.value
  sensitive   = true
}
