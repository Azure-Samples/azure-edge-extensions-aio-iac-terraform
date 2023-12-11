//noinspection HILUnresolvedReference
locals {
  existing_cluster_extension_ids = jsondecode(data.azapi_resource.aio_custom_locations.output).properties.clusterExtensionIds
}

resource "azurerm_arc_kubernetes_cluster_extension" "mq" {
  name           = "mq"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.mq"

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_extension_release_train
  version       = var.aio_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "global.quickstart"                 = "false"
    "global.openTelemetryCollectorAddr" = local.aio_otel_collector_address
    "secrets.enabled"                   = "true"
    "secrets.secretProviderClassName"   = "aio-default-spc"
    "secrets.servicePrincipalSecretRef" = "aio-secrets-store-creds"
  }
}