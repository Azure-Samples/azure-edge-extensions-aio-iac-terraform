resource "azapi_resource" "processor_instances" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsDataProcessor/instances@2023-10-04-preview"
  name                      = "dp-${var.name}"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.processor_custom_locations_sync
  ]

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {}
  })
}