resource "azurerm_arc_kubernetes_cluster_extension" "aks_secrets_provider" {
  count          = var.should_install_akv_extension ? 1 : 0
  name           = "aks-secrets-provider"
  cluster_id     = local.cluster_id
  extension_type = "Microsoft.AzureKeyVaultSecretsProvider"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "aio" {
  name           = "azure-iot-operations"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations"

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.aks_secrets_provider
  ]

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_extension_release_train
  version       = var.aio_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "rbac.cluster.admin"                      = "true"
    "aioTrust.enabled"                        = "true"
    "aioTrust.secretName"                     = var.aio_ca_secret_name
    "aioTrust.configmapName"                  = var.aio_ca_cm_name
    "aioTrust.issuerName"                     = var.aio_ca_issuer_name
    "Microsoft.CustomLocation.ServiceAccount" = "default"
    "otelCollectorAddress"                    = local.aio_otel_collector_address_no_protocol
    "genevaCollectorAddress"                  = local.aio_geneva_collector_address_no_protocol
  }
}