resource "azapi_resource" "aio_targets_opc_plc_sim" {
  count                     = var.should_install_opc_plc_simulator ? 1 : 0
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-sim"
  location                  = var.location
  parent_id                 = module.resource_group.resource_group_id

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
            resource = yamldecode(file("${path.module}/manifests/opc-plc-server/opcplc_configMap.yaml"))
          }
        },
        {
          name = "opc-plc-sim-deployment"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("${path.module}/manifests/opc-plc-server/opcplc_deployment.tftpl.yaml", {
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
            resource = yamldecode(templatefile("${path.module}/manifests/opc-plc-server/opcplc_service.tftpl.yaml", {
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
