data "azapi_resource" "aio_custom_locations" {
  type                   = "Microsoft.ExtendedLocation/customLocations@2021-08-31-preview"
  name                   = "cl-${var.name}-aio"
  parent_id              = data.azurerm_resource_group.this.id
  response_export_values = ["properties.clusterExtensionIds"]
}

resource "azapi_resource" "adr_custom_locations_sync" {
  type      = "Microsoft.ExtendedLocation/customLocations/resourceSyncRules@2021-08-31-preview"
  name      = "${data.azapi_resource.aio_custom_locations.name}-adr-sync"
  location  = var.location
  parent_id = data.azapi_resource.aio_custom_locations.id

  depends_on = [azurerm_arc_kubernetes_cluster_extension.assets]

  body = jsonencode({
    properties = {
      priority = 200
      selector = {
        matchLabels = {
          "management.azure.com/provider-name" = "Microsoft.DeviceRegistry"
        }
      }
      targetResourceGroup = data.azurerm_resource_group.this.id
    }
  })
}