resource "azurerm_arc_kubernetes_cluster_extension" "aio" {
  name           = "azure-iot-operations"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations"

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_extension_release_train
  version       = var.aio_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "rbac.cluster.admin"                      = "true"
    "aioTrust.enabled"                        = "true"
    "aioTrust.secretName"                     = var.aio_trust_secret_name
    "aioTrust.configmapName"                  = var.aio_trust_config_map_name
    "aioTrust.issuerName"                     = var.aio_trust_issuer_name
    "Microsoft.CustomLocation.ServiceAccount" = "default"
    "otelCollectorAddress"                    = local.aio_otel_collector_address_no_protocol
    "genevaCollectorAddress"                  = local.aio_geneva_collector_address_no_protocol
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "assets" {
  count = var.enable_aio_assets ? 1 : 0

  name           = "assets"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.deviceregistry.assets"

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.aio,
  ]

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_assets_extension_release_train
  version       = var.aio_assets_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "Microsoft.CustomLocation.ServiceAccount" = "default"
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "mq" {
  count = var.enable_aio_mq ? 1 : 0

  name           = "mq"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.mq"

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.aio,
  ]

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_mq_extension_release_train
  version       = var.aio_mq_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "global.quickstart"                 = "false"
    "global.openTelemetryCollectorAddr" = local.aio_otel_collector_address
    "secrets.enabled"                   = "true"
    "secrets.secretProviderClassName"   = var.aio_spc_name
    "secrets.servicePrincipalSecretRef" = var.aio_csi_secret_name
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "processor" {
  count = var.enable_aio_dataprocessor ? 1 : 0

  name           = "processor"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.dataprocessor"

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.aio,
    azurerm_arc_kubernetes_cluster_extension.mq,
  ]

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_dataprocessor_extension_release_train
  version       = var.aio_dataprocessor_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "Microsoft.CustomLocation.ServiceAccount" = "default"
    "otelCollectorAddress"                    = local.aio_otel_collector_address_no_protocol
    "genevaCollectorAddress"                  = local.aio_geneva_collector_address_no_protocol
    "cardinality.readerWorker.replicas"       = var.aio_dataprocessor_reader_count
    "cardinality.runnerWorker.replicas"       = var.aio_dataprocessor_runner_count
    "nats.config.cluster.replicas"            = var.aio_dataprocessor_message_store_count
    "secrets.secretProviderClassName"         = var.aio_spc_name
    "secrets.servicePrincipalSecretRef"       = var.aio_csi_secret_name
    "caTrust.enabled"                         = "true"
    "caTrust.configmapName"                   = var.aio_trust_config_map_name
    "serviceAccountTokens.MQClient.audience"  = var.aio_mq_auth_sat_audience
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "akri" {
  count = var.enable_aio_akri ? 1 : 0

  name           = "akri"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.akri"

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.aio,
  ]

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_akri_extension_release_train
  version       = var.aio_akri_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "webhookConfiguration.enabled" = "false"
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "layered_networking" {
  count = var.enable_aio_layered_network ? 1 : 0

  name           = "layered-networking"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.layerednetworkmanagement"

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.aio,
  ]

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_layered_network_extension_release_train
  version       = var.aio_layered_network_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {}
}