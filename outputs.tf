output "onboard_sp_object_id" {
  description = "The service principal object id for onboarding cluster to arc."
  value       = try(module.bootstrap_service_principal[0].onboard_sp_object_id, null)
}

output "onboard_sp_client_id" {
  description = "The service principal client id for onboarding cluster to arc."
  value       = try(module.bootstrap_service_principal[0].onboard_sp_client_id, null)
}

output "onboard_sp_application_password" {
  description = "The service principal secret for onboarding cluster to arc."
  value       = try(module.bootstrap_service_principal[0].onboard_sp_application_password, null)
  sensitive   = true
}

output "aio_sp_object_id" {
  description = "The service principal object id for aio in cluster."
  value       = try(module.bootstrap_service_principal[0].aio_sp_object_id, null)
}

output "aio_sp_client_id" {
  description = "The service principal client id for aio in cluster."
  value       = try(module.bootstrap_service_principal[0].aio_sp_client_id, null)
}

output "aio_sp_application_password" {
  description = "The service principal secret for aio in cluster."
  value       = try(module.bootstrap_service_principal[0].aio_sp_application_password, null)
  sensitive   = true
}

output "custom_locations_rp_object_id" {
  description = "The custom locations RP object id."
  value       = try(module.bootstrap_service_principal[0].custom_locations_rp_object_id, null)
}

output "server_setup_script" {
  description = "The server setup script to run on the server that will have the cluster and AIO"
  value       = local.linux_server_setup
}