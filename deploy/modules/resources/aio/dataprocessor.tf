resource "azapi_resource" "processor_instances" {
  count = var.enable_aio_dataprocessor ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsDataProcessor/instances@2023-10-04-preview"
  name                      = "dp-${var.name}"
  location                  = var.location
  parent_id                 = module.resource_group.resource_group_id

  depends_on = [
    azapi_resource.processor_custom_locations_sync,
    azapi_resource.aio_targets_main
  ]

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {}
  })
}