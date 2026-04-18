# Virtual Network Module

resource "azurerm_virtual_network" "vnet" {
  count = var.enabled ? 1 : 0

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.address_space

  timeouts {
    create = var.create
    delete = var.delete
  }
}