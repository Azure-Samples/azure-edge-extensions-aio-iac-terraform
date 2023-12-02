resource "azapi_resource" "aio_targets_mq" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-mq"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }

    properties = {
      "scope"   = var.aio_cluster_namespace
      "version" = var.aio_targets_main_version
      "components" = [
        {
          name = "aio-mq-fe-issuer-config"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/aio-mq-fe-issuer-config.tftpl.yaml", {
              aio_cluster_namespace              = var.aio_cluster_namespace
              aio_mq_broker_frontend_server_name = var.aio_mq_broker_frontend_server_name
            }))
          }
        }
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
