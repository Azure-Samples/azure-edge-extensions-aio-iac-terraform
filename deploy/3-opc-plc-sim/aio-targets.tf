resource "azapi_resource" "aio_targets_opc_plc_sim" {
  count                     = var.should_install_opc_plc_simulator ? 1 : 0
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-sim"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  body = jsonencode({
    extendedLocation = {
      name = local.custom_locations_id
      type = "CustomLocation"
    }

    properties = {
      "scope"   = var.aio_cluster_namespace
      "version" = var.aio_targets_main_version
      "components" = [
        {
          name = "opc-plc-sim-cm"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(file("./manifests/opc-plc-server/opcplc_configMap.yaml"))
          }
        },
        {
          name = "opc-plc-sim-deployment"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/opc-plc-server/opcplc_deployment.tftpl.yaml", {
              opc_plc_sim_server_name   = var.opc_plc_sim_server_name
              opc_plc_sim_image_version = var.opc_plc_sim_image_version
              aio_cluster_namespace     = var.aio_cluster_namespace
            }))
          }
          dependencies = ["opc-plc-sim-cm"]
        },
        {
          name = "opc-plc-sim-service"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/opc-plc-server/opcplc_service.tftpl.yaml", {
              opc_plc_sim_server_name = var.opc_plc_sim_server_name
            }))
          }
        },
      ]

      "topologies" = [
        {
          "bindings" = [
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

resource "azapi_resource" "aio_targets_mqtt_client" {
  count                     = var.should_install_insecure_mqtt_client_for_mqttui ? 1 : 0
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-mc"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  body = jsonencode({
    extendedLocation = {
      name = local.custom_locations_id
      type = "CustomLocation"
    }

    properties = {
      "scope"   = var.aio_cluster_namespace
      "version" = var.aio_targets_main_version
      "components" = [
        {
          name = "mqtt-client"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/mqtt-client-deployment.tftpl.yaml", {
              aio_mq_auth_sat_audience = var.aio_mq_auth_sat_audience
              aio_ca_cm_name           = var.aio_ca_cm_name
            }))
          }
        },
      ]

      "topologies" = [
        {
          "bindings" = [
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
