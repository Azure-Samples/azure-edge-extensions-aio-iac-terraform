locals {
  opc_plc_sim_target_address = "opc.tcp://${var.should_install_opc_plc_simulator ? var.opc_plc_sim_server_name : "opcplc-000000"}:50000"
}

resource "azapi_resource" "opc_sim_aep" {
  schema_validation_enabled = false
  type                      = "Microsoft.DeviceRegistry/assetEndpointProfiles@2023-11-01-preview"
  name                      = var.opc_sim_endpoint_name
  location                  = var.location
  parent_id                 = module.resource_group.resource_group_id

  depends_on = [azapi_resource.aio_targets_opc_plc_sim]

  body = jsonencode({
    extendedLocation = {
      name = local.custom_locations_id
      type = "CustomLocation"
    }
    properties = {
      additionalConfiguration = templatefile("${path.module}/config/opc-sim-connector-additional-config.tftpl.json", {
        opc_sim_connector_name = var.opc_sim_endpoint_name
      })
      targetAddress = local.opc_plc_sim_target_address
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
  parent_id                 = module.resource_group.resource_group_id

  body = jsonencode({
    extendedLocation = {
      name = local.custom_locations_id
      type = "CustomLocation"
    }
    properties = {
      displayName                    = var.opc_sim_asset_name
      assetEndpointProfileUri        = azapi_resource.opc_sim_aep.name
      version                        = 1
      defaultDataPointsConfiguration = jsonencode(var.opc_sim_asset_defaults)
      defaultEventsConfiguration     = jsonencode(var.opc_sim_asset_defaults)
      dataPoints                     = yamldecode(file("${path.module}/config/asset-data-points.yaml")).dataPoints
    }
  })
}
