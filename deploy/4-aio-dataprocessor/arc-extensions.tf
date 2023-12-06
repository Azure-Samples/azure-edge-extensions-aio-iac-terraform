//noinspection HILUnresolvedReference
locals {
  existing_cluster_extension_ids = jsondecode(data.azapi_resource.aio_custom_locations.output).properties.clusterExtensionIds
}

resource "azurerm_arc_kubernetes_cluster_extension" "processor" {
  name           = "processor"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.dataprocessor"

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_extension_release_train
  version       = var.aio_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "Microsoft.CustomLocation.ServiceAccount" = "default"
    "otelCollectorAddress"                    = local.aio_otel_collector_address_no_protocol
    "genevaCollectorAddress"                  = local.aio_geneva_collector_address_no_protocol
    "cardinality.readerWorker.replicas"       = var.aio_processor_reader_count
    "cardinality.runnerWorker.replicas"       = var.aio_processor_runner_count
    "nats.config.cluster.replicas"            = var.aio_processor_message_store_count
    "secrets.secretProviderClassName"         = "aio-default-spc"
    "secrets.servicePrincipalSecretRef"       = "aio-secrets-store-creds"
    "caTrust.enabled"                         = "true"
    "caTrust.configmapName"                   = var.aio_ca_cm_name
    "serviceAccountTokens.MQClient.audience"  = var.aio_mq_auth_sat_audience
  }

  provisioner "local-exec" {
    command = <<-EOT
      az customlocation patch -n ${data.azapi_resource.aio_custom_locations.name} -g ${data.azurerm_resource_group.this.name} \
        -c ${join(" ", setunion(local.existing_cluster_extension_ids, [self.id]))}
      sleep 15
    EOT
  }
}