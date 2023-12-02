resource "azapi_resource" "aio_targets_main" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-main"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.aio_custom_locations_sync
  ]

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }

    properties = {
      "scope"   = var.aio_cluster_namespace
      "version" = var.aio_targets_main_version
      "components" = [
        {
          "name" = "aio-observability"
          "type" = "helm.v3"
          "properties" = {
            "chart" = {
              "repo"    = "azureiotoperations.azurecr.io/helm/opentelemetry-collector"
              "version" = var.aio_extension_version
            }
            values = yamldecode(file("./manifests/aio-otel-collector-values.yaml"))
          }
        },
        {
          name = "aio-default-spc"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/aio-default-spc.tftpl.yaml", {
              aio_cluster_namespace = var.aio_cluster_namespace
              aio_kv_name           = data.azurerm_key_vault.aio_kv.name
              aio_tenant_id         = data.azurerm_key_vault.aio_kv.tenant_id
            }))
          }
        }
      ]

      "topologies" = [
        {
          "bindings" = [
            {
              "role"     = "helm.v3"
              "provider" = "providers.target.helm"
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
