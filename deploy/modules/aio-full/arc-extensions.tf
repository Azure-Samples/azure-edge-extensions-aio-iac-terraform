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
    "webhookConfiguration.enabled"          = "true"
    "certManagerWebhookCertificate.enabled" = "true"
    "agent.host.containerRuntimeSocket"     = var.aio_akri_container_runtime_socket # "[parameters('containerRuntimeSocket')]",
    "kubernetesDistro"                      = var.aio_akri_kubernetes_distro        # "[parameters('kubernetesDistro')]"
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

locals {
  opc_ua_broker_client_ca = {
    "securityPki.applicationCert" = var.aio_opc_ua_client_ca_spc_name
    "securityPki.subjectName"     = var.aio_opc_ua_client_ca_subject_name
    "securityPki.applicationUri"  = var.aio_opc_ua_client_ca_application_uri
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "opc_ua_broker" {
  count = var.enable_aio_opc_ua_broker ? 1 : 0

  name           = "opc-ua-broker"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.opcuabroker"

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.aio,
    azurerm_arc_kubernetes_cluster_extension.mq,
    azapi_resource.mq,
    azapi_resource.aio_targets_opc_ua_broker_trust,
    azapi_resource.aio_targets_opc_ua_client_ca,
  ]

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_opc_ua_broker_extension_release_train
  version       = var.aio_opc_ua_broker_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = merge({
    "mqttBroker.authenticationMethod"                 = "serviceAccountToken"
    "mqttBroker.serviceAccountTokenAudience"          = var.aio_mq_auth_sat_audience  # "[variables('MQ_PROPERTIES').satAudience]",
    "mqttBroker.caCertConfigMapRef"                   = var.aio_trust_config_map_name # "[variables('AIO_TRUST_CONFIG_MAP')]",
    "mqttBroker.caCertKey"                            = var.aio_ca_cm_cert_name       # "[variables('AIO_TRUST_CONFIG_MAP_KEY')]",
    "mqttBroker.address"                              = local.aio_mq_local_url        # "[variables('MQ_PROPERTIES').localUrl]",
    "mqttBroker.connectUserProperties.metriccategory" = "aio-opc"

    "opcPlcSimulation.deploy" = var.should_simulate_plc # "[format('{0}', parameters('simulatePLC'))]"

    "openTelemetry.enabled"                                = "true"
    "openTelemetry.endpoints.default.uri"                  = local.aio_otel_collector_address # "[variables('OBSERVABILITY').otelCollectorAddress]",
    "openTelemetry.endpoints.default.protocol"             = "grpc"
    "openTelemetry.endpoints.default.emitLogs"             = "false"
    "openTelemetry.endpoints.default.emitMetrics"          = "true"
    "openTelemetry.endpoints.default.emitTraces"           = "false"
    "openTelemetry.endpoints.geneva.uri"                   = local.aio_geneva_collector_address # "[variables('OBSERVABILITY').genevaCollectorAddress]",
    "openTelemetry.endpoints.geneva.protocol"              = "grpc"
    "openTelemetry.endpoints.geneva.emitLogs"              = "false"
    "openTelemetry.endpoints.geneva.emitMetrics"           = "true"
    "openTelemetry.endpoints.geneva.emitTraces"            = "false"
    "openTelemetry.endpoints.geneva.temporalityPreference" = "delta"

    "secrets.kind"                         = "csi"                   # "[parameters('opcUaBrokerSecrets').kind]",
    "secrets.csiServicePrincipalSecretRef" = var.aio_csi_secret_name # "[parameters('opcUaBrokerSecrets').csiServicePrincipalSecretRef]",
    "secrets.csiDriver"                    = "secrets-store.csi.k8s.io"
  }, var.aio_opc_ua_should_use_client_ca_spc ? local.opc_ua_broker_client_ca : {})
}