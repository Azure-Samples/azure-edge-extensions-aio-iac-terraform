resource "azapi_resource" "mq" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq@2023-10-04-preview"
  name                      = "mq-${var.name}"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [azapi_resource.mq_custom_locations_sync]

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
  })
}

resource "azapi_resource" "mq_broker" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/broker@2023-10-04-preview"
  name                      = "mq-${var.name}-bk"
  location                  = var.location
  parent_id                 = azapi_resource.mq.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      authImage = {
        pullPolicy = "Always"
        repository = "alicesprings.azurecr.io/dmqtt-authentication"
        tag        = var.aio_extension_version
      }
      brokerImage = {
        pullPolicy = "Always"
        repository = "alicesprings.azurecr.io/dmqtt-pod"
        tag        = var.aio_extension_version
      }
      healthManagerImage = {
        pullPolicy = "Always",
        repository = "alicesprings.azurecr.io/dmqtt-operator"
        tag        = var.aio_extension_version
      }
      diagnostics = {
        probeImage      = "alicesprings.azurecr.io/diagnostics-probe:${var.aio_extension_version}"
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
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/diagnosticService@2023-10-04-preview"
  name                      = "mq-${var.name}-dia"
  location                  = var.location
  parent_id                 = azapi_resource.mq.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      image = {
        repository = "alicesprings.azurecr.io/diagnostics-service"
        tag        = var.aio_extension_version
      }
      logLevel  = var.aio_mq_diag_log_level
      logFormat = var.aio_mq_diag_log_format
    }
  })
}

resource "azapi_resource" "mq_broker_listener" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/broker/listener@2023-10-04-preview"
  name                      = "${azapi_resource.mq_broker.name}-lis"
  location                  = var.location
  parent_id                 = azapi_resource.mq_broker.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      serviceType           = var.aio_mq_broker_service_type
      authenticationEnabled = true
      authorizationEnabled  = false
      brokerRef             = azapi_resource.mq_broker.name
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
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/broker/authentication@2023-10-04-preview"
  name                      = "${azapi_resource.mq_broker.name}-aut"
  location                  = var.location
  parent_id                 = azapi_resource.mq_broker.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      listenerRef = [azapi_resource.mq_broker_listener.name]
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
