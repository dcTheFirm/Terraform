provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
 
     name     = "dvops-rg"
    location = "central india"

}

resource "azurerm_virtual_network" "vnet" {
  name = "dvops-vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


 # Network interfaces for app VMs
  resource "azurerm_network_interface" "app_nic" {
    count               = 2
    name                = "app-nic-${count.index + 1}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
      name                          = "internal"
      subnet_id                     = azurerm_subnet.app.id
      private_ip_address_allocation = "Dynamic"
    }
  }

# App VMs
  resource "azurerm_linux_virtual_machine" "app_vm" {
    count               = 2
    name                = "app-vm-${count.index + 1}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size                = "Standard_B2ps_v2"
    # admin_password      = var.admin_password
    # zone                = count.index + 1         # Zone 1, 2, 3 automatically

    network_interface_ids = [
      azurerm_network_interface.app_nic[count.index].id
    ]

    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-arm64"
      version   = "latest"
    }

    # nginx installed automatically on boot
    custom_data = base64encode(<<-EOF
      #!/bin/bash
      apt update -y
      apt install nginx -y
      systemctl start nginx
      systemctl enable nginx
    EOF
    )
  }