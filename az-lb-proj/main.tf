  provider "azurerm" {
    features {}       
    }


    # Resource Group
  resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
  }


  # VNet
  resource "azurerm_virtual_network" "vnet" {
    name                = "prod-vnet"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/16"] //already declared at main.tf:1,1-18. Variable names must be unique within a module.
  }

  # Subnets
  resource "azurerm_subnet" "public" {
    name                 = "public-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
  }

  resource "azurerm_subnet" "app" {
    name                 = "app-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.2.0/24"]
  }

  resource "azurerm_subnet" "db" {
    name                 = "db-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.3.0/24"]
  }




  # Network interfaces for app VMs
  resource "azurerm_network_interface" "app_nic" {
    count               = 3
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
    count               = 3
    name                = "app-vm-${count.index + 1}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size                = "Standard_B2ps_v2"
    admin_username      = var.admin_username
    admin_password      = var.admin_password
    zone                = count.index + 1         # Zone 1, 2, 3 automatically

    disable_password_authentication = false

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


  resource "azurerm_lb" "app_lb" {
    name                = "app-internal-lb"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "Standard"

    frontend_ip_configuration {
      name                          = "app-frontend"
      subnet_id                     = azurerm_subnet.app.id
      private_ip_address            = "10.0.2.10"
      private_ip_address_allocation = "Static"
    }
  }

  resource "azurerm_lb_backend_address_pool" "app_pool" {
    name            = "app-backend-pool"
    loadbalancer_id = azurerm_lb.app_lb.id
  }

  # Connect each VM NIC to the backend pool
  resource "azurerm_network_interface_backend_address_pool_association" "app_nic_pool" {
    count                   = 3
    network_interface_id    = azurerm_network_interface.app_nic[count.index].id
    ip_configuration_name   = "internal"
    backend_address_pool_id = azurerm_lb_backend_address_pool.app_pool.id
  }

  resource "azurerm_lb_probe" "app_probe" {
    name            = "http-probe"
    loadbalancer_id = azurerm_lb.app_lb.id
    protocol        = "Http"
    port            = 80
    request_path    = "/"
    interval_in_seconds = 5
  }

  resource "azurerm_lb_rule" "app_rule" {
    name                           = "http-rule"
    loadbalancer_id                = azurerm_lb.app_lb.id
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "app-frontend"
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_pool.id]
    probe_id                       = azurerm_lb_probe.app_probe.id
  }