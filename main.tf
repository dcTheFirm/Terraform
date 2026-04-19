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


# -------------------------------
# Storage
# -------------------------------
module "storage" {
  source   = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/storage-acc"

  st_name  = "storagedc12345"
  rg_name  = module.rg.rg_name
  location = "Central India"

  tags = {
    env = "dev"
  }
}

# -------------------------------
# Key Vault
# -------------------------------
module "kv" {
  source   = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/key_vault"

  kv_name  = "dc-kv-123"
  rg_name  = module.rg.rg_name
  location = "Central India"

  tags = {
    env = "dev"
  }
}

# -------------------------------
# ACR
# -------------------------------
module "acr" {
  source   = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/ACR"

  acr_name = "dcacr123"
  rg_name  = module.rg.rg_name
  location = "Central India"

  tags = {
    env = "dev"
  }
}

# -------------------------------
# Private DNS
# -------------------------------
module "dns" {
  source = "/home/dc/Desktop/MINE/TERRAFORM/AZURE/modules/DNS"

  dns_name = "privatelink.azure.com"
  rg_name  = module.rg.rg_name
  vnet_id  = module.vnet.vnet_id
}
