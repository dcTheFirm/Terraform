provider "azurerm" {
  features {}
}


# Resource Group
# -------------------------------
module "rg" {
  source   = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/rg_group"

  name     = "dev-rg"
  location = "Central India"
  enabled  = true
}


# VNet
# -------------------------------
module "vnet" {
  source = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/vnet"

  vnet_name     = "dev-vnet"
  location      = "Central India"
  rg_name       = module.rg.rg_name
  address_space = ["10.0.0.0/16"]

  enabled = true
}


# NSG
# -------------------------------
module "nsg" {
  source = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/security_grp"

  nsg_name = "dev-nsg"
  location = "Central India"
  rg_name  = module.rg.rg_name

  enabled = true
}


# Subnet
# -------------------------------
module "subnet" {
  source = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/subnet"

  subnet_name      = "dev-subnet"
  rg_name          = module.rg.rg_name
  vnet_name        = module.vnet.vnet_name
  address_prefixes = ["10.0.1.0/24"]

  nsg_id = module.nsg.nsg_id   #  attach NSG here

  enabled = true
}
