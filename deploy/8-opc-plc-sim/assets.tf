resource "azapi_resource" "opc_sim_aep" {
  schema_validation_enabled = false
  type                      = "Microsoft.DeviceRegistry/assetEndpointProfiles@2023-11-01-preview"
  name                      = var.opc_sim_endpoint_name
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [azapi_resource.aio_targets_opc_plc_sim]

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      additionalConfiguration = templatefile("./config/opc-sim-connector-additional-config.tftpl.json", {
        opc_sim_connector_name = var.opc_sim_endpoint_name
      })
      targetAddress = "opc.tcp://${var.should_install_opc_plc_simulator ? var.opc_plc_sim_server_name : "opcplc-000000"}:50000"
      transportAuthentication = {
        ownCertificates = []
      }
      userAuthentication = {
        mode = "Anonymous"
      }
    }
  })
}

resource "azapi_resource" "opc_sim_asset" {
  schema_validation_enabled = false
  type                      = "Microsoft.DeviceRegistry/assets@2023-11-01-preview"
  name                      = var.opc_sim_asset_name
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      displayName                    = var.opc_sim_asset_name
      assetEndpointProfileUri        = azapi_resource.opc_sim_aep.name
      version                        = 1
      defaultDataPointsConfiguration = jsonencode(var.opc_sim_asset_defaults)
      defaultEventsConfiguration     = jsonencode(var.opc_sim_asset_defaults)
      dataPoints                     = yamldecode(file("./config/asset-data-points.yaml")).dataPoints
    }
  })
}
