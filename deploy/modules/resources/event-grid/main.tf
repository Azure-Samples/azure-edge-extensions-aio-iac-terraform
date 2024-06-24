
locals {
  event_grid_namespace_name = "egn-${var.name}"
  event_grid_namespace_id   = var.should_create_eventgrid_namespace ? azapi_resource.event_grid_namespace[0].id : data.azapi_resource.event_grid_namespace[0].id
  enable_mqtt_broker        = var.enable_mqtt_broker ? "Enabled" : "Disabled"
}

resource "azapi_resource" "event_grid_namespace" {
  count = var.should_create_eventgrid_namespace ? 1 : 0

  type                      = "Microsoft.EventGrid/namespaces@2023-12-15-preview"
  schema_validation_enabled = false
  name                      = local.event_grid_namespace_name
  location                  = var.location
  parent_id                 = var.resource_group_id
  tags                      = var.tags

  body = jsonencode({
    properties = {
      topicSpacesConfiguration = {
        state = local.enable_mqtt_broker
        clientAuthentication = {
          alternativeAuthenticationNameSources = var.alternative_authentication_name_sources
        }
        maximumClientSessionsPerAuthenticationName = var.maximum_client_sessions_per_authentication_name
        maximumSessionExpiryInHours                = var.maximum_session_expiry_in_hours
      }
    }
    sku = {
      capacity = var.sku_capacity
      name     = var.sku_name
    }
    identity = {
      type = "SystemAssigned"
    }
  })
}

data "azapi_resource" "event_grid_namespace" {
  count = var.should_create_eventgrid_namespace ? 0 : 1

  type      = "Microsoft.EventGrid/namespaces@2023-12-15-preview"
  name      = local.event_grid_namespace_name
  parent_id = var.resource_group_id
}

resource "azapi_resource" "event_grid_topic_spaces" {
  count = var.should_create_event_grid_topics ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.EventGrid/namespaces/topicSpaces@2023-12-15-preview"
  name                      = var.eventgrid_topic_space_name
  parent_id                 = local.event_grid_namespace_id
  body = jsonencode({
    properties = {
      "topicTemplates" = var.eventgrid_topic_templates
    }
  })
}

resource "azapi_resource" "event_grid_permission_binding_subscriber" {
  count = var.should_create_event_grid_topics ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview"
  name                      = var.eventgrid_permission_binder_subscriber_name
  parent_id                 = local.event_grid_namespace_id
  body = jsonencode({
    properties = {
      "clientGroupName" = var.eventgrid_permission_binder_subscriber_client_group_name
      "permission"      = "Subscriber"
      "topicSpaceName"  = azapi_resource.event_grid_topic_spaces[0].name
    }
  })
}

resource "azapi_resource" "event_grid_permission_binding_publisher" {
  count = var.should_create_event_grid_topics ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.EventGrid/namespaces/permissionBindings@2023-12-15-preview"
  name                      = var.eventgrid_permission_binder_publisher_name
  parent_id                 = local.event_grid_namespace_id
  body = jsonencode({
    properties = {
      "clientGroupName" = var.eventgrid_permission_binder_publisher_client_group_name
      "permission"      = "Publisher"
      "topicSpaceName"  = azapi_resource.event_grid_topic_spaces[0].name
    }
  })
}
