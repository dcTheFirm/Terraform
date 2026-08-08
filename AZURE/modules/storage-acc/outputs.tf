output "storage_name" {
  value = azurerm_storage_account.st.name
}

output "storage_id" {
  value = azurerm_storage_account.st.id
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.st.primary_blob_endpoint
}