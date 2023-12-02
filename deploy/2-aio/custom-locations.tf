resource "azapi_resource" "aio_custom_locations" {
  type      = "Microsoft.ExtendedLocation/customLocations@2021-08-31-preview"
  name      = "cl-${var.name}-aio"
  location  = var.location
  parent_id = data.azurerm_resource_group.this.id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      clusterExtensionIds = [azurerm_arc_kubernetes_cluster_extension.aio.id]
      displayName         = "cl-${var.name}-aio"
      hostResourceId      = local.cluster_id
      hostType            = "Kubernetes"
      namespace           = var.aio_cluster_namespace
    }
  })

  lifecycle {
    ignore_changes = [body]
  }
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
      targetResourceGroup = data.azurerm_resource_group.this.id
    }
  })
}