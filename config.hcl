# Simple configuration file to test initiation

storage "file" {
  path    = "$VAULT_DIR"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}