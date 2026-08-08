resource "azurerm_private_dns_zone" "dns" {
  name                = var.dns_name
  resource_group_name = var.rg_name
}

# link with VNet
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "${var.dns_name}-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = var.vnet_id
}

