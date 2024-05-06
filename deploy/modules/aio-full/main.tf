locals {
  resource_name = "${var.name}-${var.location}"
}

data "azurerm_client_config" "current" {
}

module "azure_iot_operations" {
  source = "../resources/aio"

  name                               = var.name
  location                           = var.location
  aio_mq_broker_auth_non_tls_enabled = var.aio_mq_broker_auth_non_tls_enabled
  aio_akri_kubernetes_distro         = var.kubernetes_distro
}

module "event_hub" {
  source = "../resources/event-hub"

  count                             = var.should_use_event_hub ? 1 : 0
  should_create_event_hub_namespace = false

  name                = local.resource_name
  resource_group_name = module.azure_iot_operations.resource_group_name
  location            = module.azure_iot_operations.resource_group_location

  should_create_event_hub = true
  eventhub_names          = var.aio_eh_names
  message_retention       = var.event_hub_message_retention
  partition_count         = var.event_hub_partition_count
}

module "event_grid" {
  source = "../resources/event-grid"
  count  = var.should_use_event_grid ? 1 : 0

  should_create_eventgrid_namespace = false
  name                              = local.resource_name
  location                          = module.azure_iot_operations.resource_group_location
  resource_group_id                 = module.azure_iot_operations.resource_group_id

  should_create_event_grid_topics             = true
  eventgrid_topic_space_name                  = var.aio_eg_topic_space_name
  eventgrid_topic_templates                   = var.aio_eg_topic_templates
  eventgrid_permission_binder_subscriber_name = var.aio_eg_permission_binder_subscriber_name
  eventgrid_permission_binder_publisher_name  = var.aio_eg_permission_binder_publisher_name
}
