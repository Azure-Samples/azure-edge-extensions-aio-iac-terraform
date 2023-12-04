resource "azurerm_arc_kubernetes_cluster_extension" "layered_networking" {
  name           = "layered-networking"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.layerednetworkmanagement"

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_extension_release_train
  version       = var.aio_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {}
}