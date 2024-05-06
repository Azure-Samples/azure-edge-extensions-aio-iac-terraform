locals {
  spc_obj_placeholder = <<OBJECT
        - |
          objectName: placeholder-secret
          objectType: secret
          objectVersion: ""
OBJECT
  spc_obj_cert        = <<OBJECT
        - |
          objectName: %s
          objectType: secret
          objectAlias: %s
          objectEncoding: %s
OBJECT

  opc_ua_issuer_ca_obj_list = {
    for path in toset(coalesce(var.aio_opc_ua_issuer_ca_upload_list, [])) : path => {
      path     = path
      name     = replace(basename(path), ".", "-")
      filename = basename(path)
      type     = last(split(".", basename(path)))
      encoding = "base64"
    }
  }
  opc_ua_issuer_ca_spc_obj_list = var.aio_opc_ua_should_upload_issuer_ca_list ? local.opc_ua_issuer_ca_obj_list : {
    for cert in coalesce(var.aio_opc_ua_issuer_ca_spc_list, []) : cert.filename => {
      path     = cert.filename
      name     = cert.name
      filename = cert.filename
      type     = null
      encoding = cert.encoding
    }
  }
  opc_ua_issuer_ca_spc_obj = join("\n", coalescelist([
    for key, obj in local.opc_ua_issuer_ca_spc_obj_list :
    format(local.spc_obj_cert, obj.name, obj.filename, obj.encoding)
    ], [local.spc_obj_placeholder]
  ))

  opc_ua_trust_ca_obj_list = {
    for path in toset(coalesce(var.aio_opc_ua_trust_ca_upload_list, [])) : path => {
      path     = path
      name     = replace(basename(path), ".", "-")
      filename = basename(path)
      type     = last(split(".", basename(path)))
      encoding = "base64"
    }
  }
  opc_ua_trust_ca_spc_obj_list = var.aio_opc_ua_should_upload_trust_ca_list ? local.opc_ua_trust_ca_obj_list : {
    for cert in coalesce(var.aio_opc_ua_trust_ca_spc_list, []) : cert.filename => {
      path     = cert.filename
      name     = cert.name
      filename = cert.filename
      type     = null
      encoding = cert.encoding
    }
  }
  opc_ua_trust_ca_spc_obj = join("\n", coalescelist([
    for key, obj in local.opc_ua_trust_ca_spc_obj_list :
    format(local.spc_obj_cert, obj.name, obj.filename, obj.encoding)
    ], [local.spc_obj_placeholder]
  ))

  opc_ua_client_ca_obj_list = {
    for path in toset(coalesce(var.aio_opc_ua_client_ca_upload_list, [])) : path => {
      path     = path
      name     = replace(basename(path), ".", "-")
      filename = basename(path)
      type     = last(split(".", basename(path)))
      encoding = "base64"
    }
  }
  opc_ua_client_ca_spc_obj_list = var.aio_opc_ua_should_upload_client_ca_list ? local.opc_ua_client_ca_obj_list : {
    for cert in coalesce(var.aio_opc_ua_client_ca_spc_list, []) : cert.filename => {
      path     = cert.filename
      name     = cert.name
      filename = cert.filename
      type     = null
      encoding = cert.encoding
    }
  }
  opc_ua_client_ca_spc_obj = join("\n", coalescelist([
    for key, obj in local.opc_ua_client_ca_spc_obj_list :
    format(local.spc_obj_cert, obj.name, obj.filename, obj.encoding)
    ], [local.spc_obj_placeholder]
  ))
}

resource "azapi_resource" "aio_targets_opc_ua_broker_trust" {
  count = var.enable_aio_opc_ua_broker ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-oub-trust"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.aio_custom_locations_sync,
    azapi_resource.aio_targets_main,
    azapi_resource.aio_targets_mq,
    azurerm_key_vault_secret.opc_ua_cert_pem,
    azurerm_key_vault_secret.opc_ua_cert_pkix_cert,
    azurerm_key_vault_secret.opc_ua_cert_pkix_crl,
  ]

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }

    properties = {
      scope   = var.aio_cluster_namespace
      version = var.aio_targets_main_version
      components = [
        {
          name = "aio-opc-ua-broker-trust-list"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(
              templatefile(
                "${path.module}/manifests/opc-ua-broker-certs-spc.yaml", {
                  spc_name      = "aio-opc-ua-broker-trust-list"
                  aio_kv_name   = data.azurerm_key_vault.aio_kv.name
                  aio_tenant_id = data.azurerm_key_vault.aio_kv.tenant_id
                  spc_obj_certs = local.opc_ua_trust_ca_spc_obj
                }
            ))
          }
        },
        {
          name = "aio-opc-ua-broker-issuer-list"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(
              templatefile(
                "${path.module}/manifests/opc-ua-broker-certs-spc.yaml", {
                  spc_name      = "aio-opc-ua-broker-issuer-list"
                  aio_kv_name   = data.azurerm_key_vault.aio_kv.name
                  aio_tenant_id = data.azurerm_key_vault.aio_kv.tenant_id
                  spc_obj_certs = local.opc_ua_issuer_ca_spc_obj
                }
            ))
          }
        },
      ]

      topologies = [{
        bindings = [
          {
            role     = "yaml.k8s"
            provider = "providers.target.kubectl"
            config = {
              inCluster = "true"
            }
          },
        ]
      }]
    }
  })
}

resource "azapi_resource" "aio_targets_opc_ua_client_ca" {
  count = var.enable_aio_opc_ua_broker && var.aio_opc_ua_should_use_client_ca_spc ? 1 : 0

  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-oub-cert"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.aio_custom_locations_sync,
    azapi_resource.aio_targets_main,
    azapi_resource.aio_targets_mq,
    azurerm_key_vault_secret.opc_ua_cert_pem,
    azurerm_key_vault_secret.opc_ua_cert_pkix_cert,
    azurerm_key_vault_secret.opc_ua_cert_pkix_crl,
  ]

  body = jsonencode({
    extendedLocation = {
      name = azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }

    properties = {
      scope   = var.aio_cluster_namespace
      version = var.aio_targets_main_version
      components = [
        {
          name = "aio-opc-ua-broker-client-certificate"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(
              templatefile(
                "${path.module}/manifests/opc-ua-broker-certs-spc.yaml", {
                  spc_name      = "aio-opc-ua-broker-client-certificate"
                  aio_kv_name   = data.azurerm_key_vault.aio_kv.name
                  aio_tenant_id = data.azurerm_key_vault.aio_kv.tenant_id
                  spc_obj_certs = local.opc_ua_client_ca_spc_obj
                }
            ))
          }
        },
      ]

      topologies = [{
        bindings = [
          {
            role     = "yaml.k8s"
            provider = "providers.target.kubectl"
            config = {
              inCluster = "true"
            }
          },
        ]
      }]
    }
  })
}
