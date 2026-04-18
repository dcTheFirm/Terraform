output "nsg_id" {
  value = azurerm_network_security_group.nsg[0].id
}