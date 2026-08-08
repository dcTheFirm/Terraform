output "storage_endpoint" {
  value = module.storage.primary_blob_endpoint
}

output "keyvault_uri" {
  value = module.kv.kv_uri
}

output "acr_login_server" {
  value = module.acr.login_server
}