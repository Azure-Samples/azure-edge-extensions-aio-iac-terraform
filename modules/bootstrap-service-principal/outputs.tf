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

output "aio_sp_object_id" {
  description = "The service principal object id for aio in cluster."
  value       = var.aio_sp_creation_enabled ? azuread_application.aio_sp[0].object_id : null
}

output "aio_sp_client_id" {
  description = "The service principal client id for aio in cluster."
  value       = var.aio_sp_creation_enabled ? azuread_application.aio_sp[0].client_id : null
}

output "aio_sp_application_password" {
  description = "The service principal secret for aio in cluster."
  value       = var.aio_sp_creation_enabled ? azuread_application_password.aio_sp[0].value : null
  sensitive   = true
}

output "custom_locations_rp_object_id" {
  description = "The custom locations RP object id."
  value       = data.azuread_service_principal.custom_locations_rp.object_id
}
