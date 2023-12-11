resource "azapi_resource" "aio_targets_opc_ua_broker" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-oub"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }

    properties = {
      scope   = var.aio_cluster_namespace
      version = var.aio_targets_main_version
      components = [
        {
          name = "aio-mq-fe-issuer-config"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(
              templatefile(
                "./manifests/akri-opcua-asset-discovery-daemonset.tftpl.yaml", {
                  aio_extension_version = var.aio_extension_version
                }
            ))
          }
        },
        {
          name = "opc-ua-broker"
          type = "helm.v3"
          properties = {
            chart = {
              repo    = "oci://mcr.microsoft.com/azureiotoperations/opcuabroker/helmchart/microsoft-iotoperations-opcuabroker"
              version = var.aio_extension_version
            }
            values = yamldecode(
              templatefile("./manifests/opc-ua-broker-values.tftpl.yaml", {
                aio_mq_auth_sat_audience     = var.aio_mq_auth_sat_audience
                aio_mq_local_url             = local.aio_mq_local_url
                aio_ca_cm_name               = var.aio_ca_cm_name
                aio_ca_cm_cert_name          = var.aio_ca_cm_cert_name
                should_simulate_plc          = var.should_simulate_plc
                aio_otel_collector_address   = local.aio_otel_collector_address
                aio_geneva_collector_address = local.aio_geneva_collector_address
                aio_csi_secret_name          = var.aio_csi_secret_name
              })
            )
          }
        }
      ]

      topologies = [{
        bindings = [
          {
            role     = "yaml.k8s"
            provider = "providers.target.kubectl"
            config = {
              inCluster = "true"
            }
          },
          {
            role     = "helm.v3"
            provider = "providers.target.helm"
            config = {
              inCluster = "true"
            }
          },
        ]
      }]
    }
  })
}
