resource "azapi_resource" "aio_event_grid_connector" {
  count = var.should_use_event_grid ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-event-grid-connector"
  location                  = module.azure_iot_operations.resource_group_location
  parent_id                 = module.azure_iot_operations.resource_group_id

  body = jsonencode({
    extendedLocation = {
      name = module.azure_iot_operations.aio_custom_locations_id
      type = "CustomLocation"
    }

    properties = {
      "scope"   = module.azure_iot_operations.aio_cluster_namespace
      "version" = module.azure_iot_operations.aio_targets_main_version
      "components" = [
        {
          "name" = "mqtt-bridge-connector"
          "type" = "yaml.k8s"
          "properties" = {
            "resource" = yamldecode(templatefile("${path.module}/manifests/mqtt-bridge-connector.yaml", {
              aio_mqtt_bridge_connector_name = var.aio_mqtt_bridge_connector_name
              event_grid_endpoint            = "${module.event_grid[0].eventgrid_namespace_name}.${module.azure_iot_operations.resource_group_location}-1"
              aio_cluster_namespace          = module.azure_iot_operations.aio_cluster_namespace
              aio_trust_config_map_name      = module.azure_iot_operations.aio_trust_config_map_name
            }))
          }
        },
        {
          "name" = "mqtt-bridge-topic-map"
          "type" = "yaml.k8s"
          "properties" = {
            "resource" = yamldecode(templatefile("${path.module}/manifests/mqtt-bridge-topic-map.yaml", {
              aio_cluster_namespace               = module.azure_iot_operations.aio_cluster_namespace
              aio_mqtt_bridge_topic_map_name      = var.aio_mqtt_bridge_topic_map_name
              aio_mqtt_bridge_connector_name      = var.aio_mqtt_bridge_connector_name
              aio_eg_remote_to_local_source_topic = var.aio_eg_remote_to_local_source_topic
              aio_eg_remote_to_local_target_topic = var.aio_eg_remote_to_local_target_topic
              aio_eg_local_to_remote_source_topic = var.aio_eg_local_to_remote_source_topic
              aio_eg_local_to_remote_target_topic = var.aio_eg_local_to_remote_target_topic
            }))
          }
        }
      ]

      "topologies" = [
        {
          "bindings" = [
            {
              "role"     = "instance"
              "provider" = "providers.target.k8s"
              "config" = {
                "inCluster" = "true"
              }
            },
            {
              "role" : "yaml.k8s",
              "provider" : "providers.target.kubectl",
              "config" : {
                "inCluster" : "true"
              }
            }
          ]
        }
      ]
    }
  })
}

resource "azurerm_role_assignment" "aio_mq_event_grid_topic_space_subscriber" {
  count = var.should_use_event_grid ? 1 : 0

  scope        = module.event_grid[0].eventgrid_namespace_id
  principal_id = module.azure_iot_operations.arc_kubernetes_extension_mq_identity_principal_id

  role_definition_name = "EventGrid TopicSpaces Subscriber"
}

resource "azurerm_role_assignment" "aio_mq_event_grid_topic_space_publisher" {
  count = var.should_use_event_grid ? 1 : 0

  scope        = module.event_grid[0].eventgrid_namespace_id
  principal_id = module.azure_iot_operations.arc_kubernetes_extension_mq_identity_principal_id

  role_definition_name = "EventGrid TopicSpaces Publisher"
}
