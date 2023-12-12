resource "azapi_resource" "mq" {
  count = var.enable_aio_mq ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq@2023-10-04-preview"
  name                      = "mq-${var.name}"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.mq_custom_locations_sync,
    azapi_resource.aio_targets_main,
    azapi_resource.aio_targets_mq,
  ]

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
  })
}

resource "azapi_resource" "mq_broker" {
  count = var.enable_aio_mq ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/broker@2023-10-04-preview"
  name                      = "mq-${var.name}-bk"
  location                  = var.location
  parent_id                 = azapi_resource.mq[0].id

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      authImage = {
        pullPolicy = "Always"
        repository = "mcr.microsoft.com/azureiotoperations/dmqtt-authentication"
        tag        = var.aio_mq_extension_version
      }
      brokerImage = {
        pullPolicy = "Always"
        repository = "mcr.microsoft.com/azureiotoperations/dmqtt-pod"
        tag        = var.aio_mq_extension_version
      }
      healthManagerImage = {
        pullPolicy = "Always",
        repository = "mcr.microsoft.com/azureiotoperations/dmqtt-operator"
        tag        = var.aio_mq_extension_version
      }
      diagnostics = {
        probeImage      = "mcr.microsoft.com/azureiotoperations/diagnostics-probe:${var.aio_mq_extension_version}"
        enableSelfCheck = true
      }
      mode          = var.aio_mq_mode
      memoryProfile = var.aio_mq_memory_profile
      cardinality = {
        backendChain = {
          partitions       = var.aio_mq_backend_partition_count
          workers          = var.aio_mq_backend_worker_count
          redundancyFactor = var.aio_mq_backend_redundancy_factor_count
        }
        frontend = {
          replicas = var.aio_mq_frontend_replica_count
          workers  = var.aio_mq_frontend_worker_count
        }
      }
    }
  })
}

resource "azapi_resource" "mq_diagnostics" {
  count = var.enable_aio_mq ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/diagnosticService@2023-10-04-preview"
  name                      = "mq-${var.name}-dia"
  location                  = var.location
  parent_id                 = azapi_resource.mq[0].id

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      image = {
        repository = "mcr.microsoft.com/azureiotoperations/diagnostics-service"
        tag        = var.aio_mq_extension_version
      }
      logLevel  = var.aio_mq_diag_log_level
      logFormat = var.aio_mq_diag_log_format
    }
  })
}

resource "azapi_resource" "mq_broker_listener" {
  count = var.enable_aio_mq ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/broker/listener@2023-10-04-preview"
  name                      = "${azapi_resource.mq_broker[0].name}-lis"
  location                  = var.location
  parent_id                 = azapi_resource.mq_broker[0].id

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      serviceType           = var.aio_mq_broker_service_type
      authenticationEnabled = true
      authorizationEnabled  = false
      brokerRef             = azapi_resource.mq_broker[0].name
      port                  = 8883
      tls = {
        automatic = {
          issuerRef = {
            name  = var.aio_mq_broker_frontend_server_name
            kind  = "Issuer"
            group = "cert-manager.io"
          }
        }
      }
    }
  })
}

resource "azapi_resource" "mq_broker_auth" {
  count = var.enable_aio_mq ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/broker/authentication@2023-10-04-preview"
  name                      = "${azapi_resource.mq_broker[0].name}-aut"
  location                  = var.location
  parent_id                 = azapi_resource.mq_broker[0].id

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      listenerRef = [azapi_resource.mq_broker_listener[0].name]
      authenticationMethods = [
        {
          sat = {
            audiences = [var.aio_mq_auth_sat_audience]
          }
        }
      ]
    }
  })
}
