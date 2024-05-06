resource "azapi_resource" "aio_mqtt_client" {
  count = var.should_deploy_mqtt_client ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-mqtt-client"
  location                  = var.location
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
          "name" = "mqtt-client"
          "type" = "yaml.k8s"
          "properties" = {
            "resource" = yamldecode(templatefile("${path.module}/manifests/mqtt-client.yaml", {
              aio_cluster_namespace     = module.azure_iot_operations.aio_cluster_namespace
              aio_mq_auth_sat_audience  = var.aio_mq_auth_sat_audience
              aio_trust_config_map_name = module.azure_iot_operations.aio_trust_config_map_name
            }))
          }
        },
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
