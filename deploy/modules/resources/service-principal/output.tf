output "service_principal_aio_onboard_object_id" {
  description = "Service Principal AIO Onboard Object ID"
  value       = local.sp_onboard_object_id
}

output "service_principal_aio_onboard_client_id" {
  description = "Service Principal AIO Onboard Client ID"
  value       = local.sp_onboard_client_id
}

output "service_principal_aio_onboard_application_password" {
  description = "Service Principal AIO Onboard Secret"
  value       = var.should_create_onboard_sp_secret ? azuread_application_password.sp_onboard[0].value : ""
  sensitive   = true
}

output "service_principal_aio_object_id" {
  description = "Service Principal AIO Object ID"
  value       = local.sp_object_id
}

output "service_principal_aio_client_id" {
  description = "Service Principal AIO Client ID"
  value       = local.sp_client_id
}

output "service_principal_aio_password" {
  description = "Service Principal AIO Secret"
  value       = var.should_create_sp_secret ? azuread_application_password.sp[0].value : ""
  sensitive   = true
}

output "custom_locations_rp" {
  description = "Custom Locations RP"
  value       = data.azuread_service_principal.custom_locations_rp.object_id
}
