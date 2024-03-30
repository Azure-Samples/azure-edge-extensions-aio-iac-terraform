///
// Generate self-signed certificate and key for use with AIO.
//
// Note: In a production scenario, the certificate and key should be generated and signed
// by a trusted CA.
///

resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  validity_period_hours = 8076
  allowed_uses          = ["cert_signing"]
  is_ca_certificate     = true
  set_authority_key_id  = true
  set_subject_key_id    = true
  subject {
    common_name = "AIO Root CA - Self Signed"
  }
}