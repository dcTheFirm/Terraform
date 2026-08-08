# since count is used -> index [0]

output "rg_name" {
  value = azurerm_resource_group.rg[0].name
}

output "rg_id" {
  value = azurerm_resource_group.rg[0].id
}