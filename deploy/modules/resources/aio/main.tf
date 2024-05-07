locals {
  resource_name    = "${var.name}-${var.location}"
  aio_cluster_name = var.arc_cluster_name == null ? "arc-${local.resource_name}" : var.arc_cluster_name
  cluster_id       = "${module.resource_group.resource_group_id}/providers/Microsoft.Kubernetes/connectedClusters/${local.aio_cluster_name}"

  aio_otel_collector_address_no_protocol   = "aio-otel-collector.${var.aio_cluster_namespace}.svc.cluster.local:4317"
  aio_geneva_collector_address_no_protocol = "geneva-metrics-service.${var.aio_cluster_namespace}.svc.cluster.local:4317"

  aio_otel_collector_address   = "http://${local.aio_otel_collector_address_no_protocol}"
  aio_geneva_collector_address = "http://${local.aio_geneva_collector_address_no_protocol}"

  aio_mq_domain    = "${var.aio_mq_frontend_server}.${var.aio_cluster_namespace}"
  aio_mq_local_url = "mqtts://${local.aio_mq_domain}:8883"
}

data "azurerm_client_config" "current" {
}

module "resource_group" {
  source                       = "../resource-group"
  should_create_resource_group = false

  name                = local.resource_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "key_vault" {
  source                           = "../key-vault"
  should_create_key_vault          = false
  should_create_key_vault_policies = false

  name                = local.resource_name
  key_vault_name      = var.key_vault_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
}
