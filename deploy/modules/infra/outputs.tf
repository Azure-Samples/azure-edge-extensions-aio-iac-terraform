output "resource_group_name" {
  description = "Resource Group Name"
  value       = module.resource_group.resource_group_name
}

output "service_principal_aio_object_id" {
  description = "Service Principal AIO Object ID"
  value       = module.service_principal.service_principal_aio_object_id
}

output "service_principal_aio_onboard_client_id" {
  description = "Service Principal AIO Onboard Client ID"
  value       = module.service_principal.service_principal_aio_onboard_client_id
}

output "service_principal_aio_onboard_client_secret" {
  description = "Service Principal AIO Onboard Client Secret"
  value       = module.service_principal.service_principal_aio_onboard_application_password
  sensitive   = true
}

output "server_setup_script" {
  description = "Server Setup Script"
  value       = local.server_setup
  sensitive   = true
}
