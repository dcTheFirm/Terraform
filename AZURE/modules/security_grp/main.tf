# Network Security Group Module
# used to control inbound/outbound traffic

resource "azurerm_network_security_group" "nsg" {
  count = var.enabled ? 1 : 0

  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.rg_name

  # basic rule (allow SSH for demo)
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}