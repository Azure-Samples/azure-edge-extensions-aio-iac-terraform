locals {
  upload_opc_ua_issuer_ca_obj_list = var.aio_opc_ua_should_upload_issuer_ca_list ? local.opc_ua_issuer_ca_obj_list : {}
  upload_opc_ua_trust_ca_obj_list  = var.aio_opc_ua_should_upload_trust_ca_list ? local.opc_ua_trust_ca_obj_list : {}
  upload_opc_ua_cert_ca_obj_list   = var.aio_opc_ua_should_upload_client_ca_list ? local.opc_ua_client_ca_obj_list : {}

  opc_ua_cert_obj_list = merge(local.upload_opc_ua_issuer_ca_obj_list, local.upload_opc_ua_trust_ca_obj_list, local.upload_opc_ua_cert_ca_obj_list)

  opc_ua_cert_pkix_cert = {
    for path, file in local.opc_ua_cert_obj_list : path => file
    if file.type == "der"
  }
  opc_ua_cert_pkix_crl = {
    for path, file in local.opc_ua_cert_obj_list : path => file
    if file.type == "crl"
  }
  opc_ua_cert_pem = {
    for path, file in local.opc_ua_cert_obj_list : path => file
    if file.type == "crt"
  }
}

resource "azurerm_key_vault_secret" "opc_ua_cert_pkix_cert" {
  for_each = local.opc_ua_cert_pkix_cert

  key_vault_id = data.azurerm_key_vault.aio_kv.id
  name         = each.value.name
  value        = filebase64(each.key)
  content_type = "application/pkix-cert"
  tags = {
    "file-encoding" = "base64"
  }
}

resource "azurerm_key_vault_secret" "opc_ua_cert_pkix_crl" {
  for_each = local.opc_ua_cert_pkix_crl

  key_vault_id = data.azurerm_key_vault.aio_kv.id
  name         = each.value.name
  value        = filebase64(each.key)
  content_type = "application/pkix-crl"
  tags = {
    "file-encoding" = "base64"
  }
}

resource "azurerm_key_vault_secret" "opc_ua_cert_pem" {
  for_each = local.opc_ua_cert_pkix_crl

  key_vault_id = data.azurerm_key_vault.aio_kv.id
  name         = each.value.name
  value        = filebase64(each.key)
  content_type = "application/x-pem-file"
  tags = {
    "file-encoding" = "base64"
  }
}
