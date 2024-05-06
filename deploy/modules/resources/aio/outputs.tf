output "aio_cluster_namespace" {
  value = var.aio_cluster_namespace
}

output "aio_trust_config_map_name" {
  value = var.aio_trust_config_map_name
}

output "aio_targets_main_version" {
  value = var.aio_targets_main_version
}

output "aio_custom_locations_id"{
  value = azapi_resource.aio_custom_locations.id
}

output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "resource_group_id" {
  value = module.resource_group.resource_group_id
}

output "resource_group_location" {
  value = module.resource_group.resource_group_location
}

output "arc_kubernetes_extension_mq_identity_principal_id" {
  value = var.enable_aio_mq ? azurerm_arc_kubernetes_cluster_extension.mq[0].identity[0].principal_id : null
}
