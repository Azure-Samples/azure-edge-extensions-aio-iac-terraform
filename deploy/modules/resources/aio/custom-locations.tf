resource "azapi_resource" "aio_custom_locations" {
  type      = "Microsoft.ExtendedLocation/customLocations@2021-08-31-preview"
  name      = "cl-${var.name}-aio"
  location  = var.location
  parent_id = module.resource_group.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      clusterExtensionIds = [
        azurerm_arc_kubernetes_cluster_extension.aio.id,
        azurerm_arc_kubernetes_cluster_extension.assets[0].id,
        azurerm_arc_kubernetes_cluster_extension.processor[0].id,
        azurerm_arc_kubernetes_cluster_extension.mq[0].id,
      ]
      displayName    = "cl-${var.name}-aio"
      hostResourceId = local.cluster_id
      hostType       = "Kubernetes"
      namespace      = var.aio_cluster_namespace
    }
  })
}

resource "azapi_resource" "aio_custom_locations_sync" {
  type      = "Microsoft.ExtendedLocation/customLocations/resourceSyncRules@2021-08-31-preview"
  name      = "${azapi_resource.aio_custom_locations.name}-sync"
  location  = var.location
  parent_id = azapi_resource.aio_custom_locations.id

  body = jsonencode({
    properties = {
      priority = 100
      selector = {
        matchLabels = {
          "management.azure.com/provider-name" = "microsoft.iotoperationsorchestrator"
        }
      }
      targetResourceGroup = module.resource_group.resource_group_id
    }
  })
}

resource "azapi_resource" "adr_custom_locations_sync" {
  count = var.enable_aio_assets ? 1 : 0

  type      = "Microsoft.ExtendedLocation/customLocations/resourceSyncRules@2021-08-31-preview"
  name      = "${azapi_resource.aio_custom_locations.name}-adr-sync"
  location  = var.location
  parent_id = azapi_resource.aio_custom_locations.id

  depends_on = [
    azapi_resource.mq_custom_locations_sync
  ]

  body = jsonencode({
    properties = {
      priority = 200
      selector = {
        matchLabels = {
          "management.azure.com/provider-name" = "Microsoft.DeviceRegistry"
        }
      }
      targetResourceGroup = module.resource_group.resource_group_id
    }
  })
}

resource "azapi_resource" "processor_custom_locations_sync" {
  count = var.enable_aio_dataprocessor ? 1 : 0

  type      = "Microsoft.ExtendedLocation/customLocations/resourceSyncRules@2021-08-31-preview"
  name      = "${azapi_resource.aio_custom_locations.name}-dp-sync"
  location  = var.location
  parent_id = azapi_resource.aio_custom_locations.id

  depends_on = [
    azapi_resource.aio_custom_locations_sync
  ]

  body = jsonencode({
    properties = {
      priority = 300
      selector = {
        matchLabels = {
          "management.azure.com/provider-name" = "microsoft.iotoperationsdataprocessor"
        }
      }
      targetResourceGroup = module.resource_group.resource_group_id
    }
  })
}

resource "azapi_resource" "mq_custom_locations_sync" {
  count = var.enable_aio_mq ? 1 : 0

  type      = "Microsoft.ExtendedLocation/customLocations/resourceSyncRules@2021-08-31-preview"
  name      = "${azapi_resource.aio_custom_locations.name}-mq-sync"
  location  = var.location
  parent_id = azapi_resource.aio_custom_locations.id

  depends_on = [
    azapi_resource.processor_custom_locations_sync
  ]

  body = jsonencode({
    properties = {
      priority = 400
      selector = {
        matchLabels = {
          "management.azure.com/provider-name" = "microsoft.iotoperationsmq"
        }
      }
      targetResourceGroup = module.resource_group.resource_group_id
    }
  })
}
