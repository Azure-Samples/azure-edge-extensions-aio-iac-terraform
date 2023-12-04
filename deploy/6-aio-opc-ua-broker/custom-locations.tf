data "azapi_resource" "aio_custom_locations" {
  type                   = "Microsoft.ExtendedLocation/customLocations@2021-08-31-preview"
  name                   = "cl-${var.name}-aio"
  parent_id              = data.azurerm_resource_group.this.id
  response_export_values = ["properties.clusterExtensionIds"]
}