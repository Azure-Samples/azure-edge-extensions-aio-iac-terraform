output "onboard_sp_object_id" {
  description = "The service principal object id for onboarding cluster to arc."
  value       = var.onboard_sp_creation_enabled ? azuread_application.onboard_sp[0].object_id : null
}

output "onboard_sp_client_id" {
  description = "The service principal client id for onboarding cluster to arc."
  value       = var.onboard_sp_creation_enabled ? azuread_application.onboard_sp[0].client_id : null
}

output "onboard_sp_application_password" {
  description = "The service principal secret for onboarding cluster to arc."
  value       = var.onboard_sp_creation_enabled ? azuread_application_password.onboard_sp[0].value : null
  sensitive   = true
}
