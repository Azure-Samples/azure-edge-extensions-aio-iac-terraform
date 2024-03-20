resource "azapi_resource" "aio_targets_main" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
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
              "repo"    = "mcr.microsoft.com/azureiotoperations/helm/aio-opentelemetry-collector"
              "version" = var.aio_observability_version
            }
            values = yamldecode(file("${path.module}/manifests/aio-otel-collector-values.yaml"))
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

resource "azapi_resource" "aio_targets_mq" {
  count = var.enable_aio_mq ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-mq"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.aio_custom_locations_sync,
    azapi_resource.aio_targets_main
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
          name = "aio-mq-fe-issuer-config"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("${path.module}/manifests/aio-mq-fe-issuer-config.tftpl.yaml", {
              aio_cluster_namespace              = var.aio_cluster_namespace
              aio_mq_broker_frontend_server_name = var.aio_mq_broker_frontend_server_name
              aio_trust_secret_name              = var.aio_trust_secret_name
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

resource "azapi_resource" "aio_targets_opc_ua_broker" {
  count = var.enable_aio_opc_ua_broker ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-oub"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.aio_custom_locations_sync,
    azapi_resource.aio_targets_main,
    azapi_resource.aio_targets_mq
  ]

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
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
                "${path.module}/manifests/aio-opc-asset-discovery.tftpl.yaml", {
                  aio_extension_version = var.aio_opc_ua_broker_extension_version
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
              version = var.aio_opc_ua_broker_extension_version
            }
            values = yamldecode(
              templatefile("${path.module}/manifests/opc-ua-broker-values.tftpl.yaml", {
                aio_mq_auth_sat_audience     = var.aio_mq_auth_sat_audience
                aio_mq_local_url             = local.aio_mq_local_url
                aio_trust_config_map_name    = var.aio_trust_config_map_name
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