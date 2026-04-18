resource "azurerm_subnet" "subnet" {
  count = var.enabled ? 1 : 0

  name                 = var.subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
}

# attaching NSG to subnet
resource "azurerm_subnet_network_security_group_association" "nsg_attach" {
  count = var.enabled ? 1 : 0

  subnet_id                 = azurerm_subnet.subnet[0].id
  network_security_group_id = var.nsg_id
}