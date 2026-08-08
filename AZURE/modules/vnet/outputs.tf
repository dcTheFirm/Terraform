output "vnet_name" {
  value = azurerm_virtual_network.vnet[0].name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet[0].id
}