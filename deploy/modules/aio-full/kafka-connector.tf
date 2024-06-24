resource "azapi_resource" "aio_kafka_connector" {
  count = var.should_use_event_hub ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-kafka-connector"
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
          "name" = "kafka-connector"
          "type" = "yaml.k8s"
          "properties" = {
            "resource" = yamldecode(templatefile("${path.module}/manifests/kafka-connector.yaml", {
              aio_eh_kafka_connector_name = var.aio_eh_kafka_connector_name
              event_hub_namespace         = module.event_hub[0].eventhub_namespace_name
              aio_cluster_namespace       = module.azure_iot_operations.aio_cluster_namespace
              aio_trust_config_map_name   = module.azure_iot_operations.aio_trust_config_map_name
            }))
          }
        },
        {
          "name" = "kafka-connector-topic-map"
          "type" = "yaml.k8s"
          "properties" = {
            "resource" = yamldecode(templatefile("${path.module}/manifests/kafka-connector-topic-map.yaml", {
              aio_cluster_namespace                 = module.azure_iot_operations.aio_cluster_namespace
              aio_eh_kafka_connector_topic_map_name = var.aio_eh_kafka_connector_topic_map_name
              aio_eh_kafka_connector_name           = var.aio_eh_kafka_connector_name
              aio_eh_edge_to_cloud_mqtt_topic       = var.aio_eh_edge_to_cloud_mqtt_topic
              aio_eh_edge_to_cloud_kafka_topic      = var.aio_eh_edge_to_cloud_kafka_topic
              aio_eh_cloud_to_edge_mqtt_topic       = var.aio_eh_cloud_to_edge_mqtt_topic
              aio_eh_cloud_to_edge_kafka_topic      = var.aio_eh_cloud_to_edge_kafka_topic
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

resource "azurerm_role_assignment" "aio_mq_event_hub_data_receiver" {
  count = var.should_use_event_hub ? 1 : 0

  scope        = module.event_hub[0].eventhub_namespace_id
  principal_id = module.azure_iot_operations.arc_kubernetes_extension_mq_identity_principal_id

  role_definition_name = "Azure Event Hubs Data Receiver"
}

resource "azurerm_role_assignment" "aio_mq_event_hub_data_sender" {
  count = var.should_use_event_hub ? 1 : 0

  scope        = module.event_hub[0].eventhub_namespace_id
  principal_id = module.azure_iot_operations.arc_kubernetes_extension_mq_identity_principal_id

  role_definition_name = "Azure Event Hubs Data Sender"
}
